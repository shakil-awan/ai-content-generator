/**
 * Firebase Cloud Functions for AI Content Generator
 * 
 * NIGHTLY ACCOUNT DELETION PROCESSOR
 * - Runs every night at 2:00 AM UTC
 * - Checks for accounts scheduled for deletion
 * - Processes deletions if date has passed
 * - Preserves payment/billing records for compliance
 * - Deletes user data, content, and storage files
 * 
 * DEPLOYMENT:
 *   cd firebase_functions
 *   npm install
 *   firebase deploy --only functions
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

/**
 * NIGHTLY ACCOUNT DELETION PROCESSOR
 * 
 * Scheduled to run every night at 2:00 AM UTC
 * Checks for accounts with deletion_scheduled_for date passed
 * 
 * Process:
 * 1. Query users with account_status='pending_deletion'
 * 2. Check if deletion_scheduled_for <= now
 * 3. For each account:
 *    a. Delete user data from Firestore (except payments)
 *    b. Delete files from Storage
 *    c. Delete Firebase Auth user
 *    d. Log deletion for audit trail
 */
exports.processScheduledAccountDeletions = functions.pubsub
    .schedule('0 2 * * *')  // Runs at 2:00 AM UTC daily
    .timeZone('UTC')
    .onRun(async (context) => {
        console.log('🗑️  Starting nightly account deletion processor...');

        const now = admin.firestore.Timestamp.now();
        const deletionLog = [];

        try {
            // 1. Query accounts pending deletion
            const usersSnapshot = await db.collection('users')
                .where('account_status', '==', 'pending_deletion')
                .get();

            console.log(`Found ${usersSnapshot.size} accounts pending deletion`);

            if (usersSnapshot.empty) {
                console.log('✅ No accounts to delete');
                return null;
            }

            // 2. Process each account
            for (const userDoc of usersSnapshot.docs) {
                const userData = userDoc.data();
                const userId = userDoc.id;

                // Check if deletion date has passed
                const scheduledFor = userData.deletion_scheduled_for;
                if (!scheduledFor || scheduledFor.toMillis() > now.toMillis()) {
                    console.log(`⏳ Skipping ${userId} - deletion scheduled for ${scheduledFor?.toDate()}`);
                    continue;
                }

                console.log(`🗑️  Processing deletion for user: ${userId}`);

                try {
                    // Delete user data (uses helper function below)
                    await deleteUserData(userId, userData);

                    deletionLog.push({
                        userId,
                        email: userData.email,
                        deletedAt: now.toDate(),
                        reason: userData.deletion_reason || 'No reason provided',
                        status: 'success'
                    });

                    console.log(`✅ Successfully deleted account: ${userId}`);

                } catch (error) {
                    console.error(`❌ Error deleting account ${userId}:`, error);

                    deletionLog.push({
                        userId,
                        email: userData.email,
                        deletedAt: now.toDate(),
                        status: 'failed',
                        error: error.message
                    });
                }
            }

            // 3. Log deletions to audit collection
            if (deletionLog.length > 0) {
                await db.collection('deletion_audit_log').add({
                    batch_date: now.toDate(),
                    processed_count: deletionLog.length,
                    deletions: deletionLog,
                    created_at: now
                });
            }

            console.log(`✅ Nightly deletion processor completed. Deleted ${deletionLog.length} accounts`);
            return null;

        } catch (error) {
            console.error('❌ Error in nightly deletion processor:', error);
            throw error;
        }
    });

/**
 * DELETE USER DATA
 * 
 * Comprehensive deletion of user data while preserving payment records
 * 
 * DELETES:
 * - User document from 'users' collection
 * - Generated content from 'generations' collection
 * - Brand voice data from 'brand_voices' collection
 * - User settings and preferences
 * - Files from Firebase Storage (images, videos)
 * - Firebase Authentication account
 * 
 * PRESERVES:
 * - Payment records in 'payments' collection
 * - Billing history in 'billing_history' collection
 * - Stripe subscription records (for tax/legal compliance)
 * - Transaction logs in 'transactions' collection
 * 
 * @param {string} userId - User ID to delete
 * @param {object} userData - User data document
 */
async function deleteUserData(userId, userData) {
    console.log(`📦 Deleting data for user: ${userId}`);

    const batch = db.batch();

    try {
        // 1. DELETE: Generated content history
        const generationsSnapshot = await db.collection('generations')
            .where('user_id', '==', userId)
            .get();

        console.log(`  📝 Deleting ${generationsSnapshot.size} generations`);
        generationsSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // 2. DELETE: Brand voice configurations
        const brandVoicesSnapshot = await db.collection('brand_voices')
            .where('user_id', '==', userId)
            .get();

        console.log(`  🎙️  Deleting ${brandVoicesSnapshot.size} brand voices`);
        brandVoicesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // 3. DELETE: User favorites
        const favoritesSnapshot = await db.collection('favorites')
            .where('user_id', '==', userId)
            .get();

        console.log(`  ⭐ Deleting ${favoritesSnapshot.size} favorites`);
        favoritesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // 4. DELETE: User sessions
        const sessionsSnapshot = await db.collection('sessions')
            .where('user_id', '==', userId)
            .get();

        console.log(`  🔒 Deleting ${sessionsSnapshot.size} sessions`);
        sessionsSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });

        // 5. DELETE: Files from Firebase Storage
        await deleteUserStorage(userId);

        // 6. PRESERVE: Payment records (add deletion marker but keep data)
        const paymentsSnapshot = await db.collection('payments')
            .where('user_id', '==', userId)
            .get();

        console.log(`  💳 Marking ${paymentsSnapshot.size} payment records (preserved for compliance)`);
        paymentsSnapshot.docs.forEach(doc => {
            batch.update(doc.ref, {
                user_deleted: true,
                user_deleted_at: admin.firestore.Timestamp.now(),
                // Keep all payment data intact for tax/legal compliance
            });
        });

        // 7. PRESERVE: Billing history (add deletion marker)
        const billingSnapshot = await db.collection('billing_history')
            .where('user_id', '==', userId)
            .get();

        console.log(`  📊 Marking ${billingSnapshot.size} billing records (preserved for compliance)`);
        billingSnapshot.docs.forEach(doc => {
            batch.update(doc.ref, {
                user_deleted: true,
                user_deleted_at: admin.firestore.Timestamp.now(),
            });
        });

        // 8. DELETE: User document (main profile)
        const userRef = db.collection('users').doc(userId);
        batch.delete(userRef);
        console.log(`  👤 Deleting user document`);

        // 9. Commit all Firestore deletions
        await batch.commit();
        console.log(`  ✅ Firestore deletions committed`);

        // 10. DELETE: Firebase Authentication account
        try {
            await admin.auth().deleteUser(userId);
            console.log(`  🔐 Deleted Firebase Auth account`);
        } catch (authError) {
            console.error(`  ⚠️  Could not delete Auth account (may already be deleted):`, authError.message);
        }

        console.log(`✅ User data deletion complete for: ${userId}`);

    } catch (error) {
        console.error(`❌ Error deleting user data:`, error);
        throw error;
    }
}

/**
 * DELETE USER STORAGE FILES
 * 
 * Deletes all files uploaded by the user:
 * - Profile images
 * - Generated images
 * - Video content
 * - Brand voice samples
 * 
 * @param {string} userId - User ID
 */
async function deleteUserStorage(userId) {
    console.log(`  🗂️  Deleting storage files for user: ${userId}`);

    try {
        const bucket = storage.bucket();

        // Delete all files in user's directory
        const [files] = await bucket.getFiles({
            prefix: `users/${userId}/`
        });

        console.log(`  📁 Found ${files.length} files to delete`);

        if (files.length === 0) {
            console.log(`  ℹ️  No storage files to delete`);
            return;
        }

        // Delete files in batches of 50 (avoid rate limits)
        const batchSize = 50;
        for (let i = 0; i < files.length; i += batchSize) {
            const batch = files.slice(i, i + batchSize);
            await Promise.all(batch.map(file => file.delete()));
            console.log(`  🗑️  Deleted batch ${Math.floor(i / batchSize) + 1} (${batch.length} files)`);
        }

        console.log(`  ✅ Storage files deleted successfully`);

    } catch (error) {
        console.error(`  ❌ Error deleting storage files:`, error);
        // Don't throw - continue with deletion even if storage cleanup fails
    }
}

/**
 * MANUAL DELETION TRIGGER (HTTP Endpoint)
 * 
 * For testing or manual intervention
 * 
 * POST https://us-central1-<project-id>.cloudfunctions.net/manualAccountDeletion
 * Body: { "userId": "user123" }
 * Authorization: Bearer <admin-token>
 */
exports.manualAccountDeletion = functions.https.onCall(async (data, context) => {
    // Verify admin authentication
    if (!context.auth || !context.auth.token.admin) {
        throw new functions.https.HttpsError(
            'permission-denied',
            'Only administrators can manually delete accounts'
        );
    }

    const { userId } = data;

    if (!userId) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'userId is required'
        );
    }

    try {
        // Get user data
        const userDoc = await db.collection('users').doc(userId).get();

        if (!userDoc.exists) {
            throw new functions.https.HttpsError(
                'not-found',
                `User ${userId} not found`
            );
        }

        const userData = userDoc.data();

        // Delete user data
        await deleteUserData(userId, userData);

        // Log manual deletion
        await db.collection('deletion_audit_log').add({
            type: 'manual',
            userId,
            email: userData.email,
            deletedAt: admin.firestore.Timestamp.now(),
            deletedBy: context.auth.uid,
            reason: 'Manual deletion by administrator'
        });

        return {
            success: true,
            message: `Account ${userId} deleted successfully`
        };

    } catch (error) {
        console.error('Error in manual deletion:', error);
        throw new functions.https.HttpsError(
            'internal',
            `Failed to delete account: ${error.message}`
        );
    }
});

/**
 * GET DELETION AUDIT LOG (HTTP Endpoint)
 * 
 * Retrieve deletion audit logs for compliance
 * 
 * GET https://us-central1-<project-id>.cloudfunctions.net/getDeletionAuditLog?startDate=2025-01-01&endDate=2025-12-31
 * Authorization: Bearer <admin-token>
 */
exports.getDeletionAuditLog = functions.https.onCall(async (data, context) => {
    // Verify admin authentication
    if (!context.auth || !context.auth.token.admin) {
        throw new functions.https.HttpsError(
            'permission-denied',
            'Only administrators can access deletion audit logs'
        );
    }

    const { startDate, endDate, limit = 50 } = data;

    try {
        let query = db.collection('deletion_audit_log')
            .orderBy('batch_date', 'desc')
            .limit(limit);

        if (startDate) {
            query = query.where('batch_date', '>=', new Date(startDate));
        }

        if (endDate) {
            query = query.where('batch_date', '<=', new Date(endDate));
        }

        const snapshot = await query.get();

        const logs = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            batch_date: doc.data().batch_date.toDate()
        }));

        return {
            success: true,
            logs,
            count: logs.length
        };

    } catch (error) {
        console.error('Error fetching audit logs:', error);
        throw new functions.https.HttpsError(
            'internal',
            `Failed to fetch audit logs: ${error.message}`
        );
    }
});
