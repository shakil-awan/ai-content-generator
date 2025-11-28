"""
Smart Fact-Checking Service with Google Custom Search API
Budget-friendly: Only checks important claims, uses caching
"""

import os
import logging
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import google.generativeai as genai
import requests
import hashlib
import json
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

@dataclass
class SourceDetails:
    """Detailed source information for fact-checking"""
    url: str
    title: str
    snippet: str
    domain: str
    authority_level: str  # 'government', 'academic', 'organization', 'news', 'general'

@dataclass
class FactCheckClaim:
    """Individual factual claim"""
    claim: str
    verified: bool
    confidence: float  # 0-1
    sources: List[SourceDetails]  # Enhanced with detailed source info!
    evidence: str

@dataclass
class FactCheckResult:
    """Fact-checking result"""
    checked: bool
    claims_found: int
    claims_verified: int
    claims: List[FactCheckClaim]
    overall_confidence: float  # 0-1
    verification_time: float  # seconds
    total_searches_used: int = 0  # Transparency: show API usage
    
    def to_dict(self) -> Dict:
        return {
            'checked': self.checked,
            'claims_found': self.claims_found,
            'claims_verified': self.claims_verified,
            'claims': [asdict(c) for c in self.claims],
            'overall_confidence': self.overall_confidence,
            'verification_time': self.verification_time,
            'total_searches_used': self.total_searches_used
        }


class SmartFactChecker:
    """
    Budget-friendly fact-checking with Gemini + Google Custom Search
    
    Strategy:
    1. Use Gemini to extract only verifiable factual claims
    2. Verify only the most important 2-3 claims (not all)
    3. Cache results to avoid duplicate searches
    4. Skip fact-checking for short or opinion-based content
    
    Cost: ~100 free searches/day, then $5/1000 queries
    """
    
    def __init__(self):
        """Initialize Gemini and Google Custom Search"""
        # Gemini for claim extraction
        api_key = os.getenv('GEMINI_API_KEY')
        if not api_key:
            raise ValueError("GEMINI_API_KEY environment variable not set")
        
        genai.configure(api_key=api_key)
        from app.config import ModelConfig
        self.gemini_model = genai.GenerativeModel(ModelConfig.FACT_CHECK_MODEL)
        
        # Google Custom Search API
        self.search_api_key = os.getenv('GOOGLE_SEARCH_API_KEY')
        self.search_engine_id = os.getenv('GOOGLE_SEARCH_ENGINE_ID')
        
        if not self.search_api_key or not self.search_engine_id:
            logger.warning("⚠️ Google Search API credentials not configured - fact-checking disabled")
            self.search_enabled = False
        else:
            self.search_enabled = True
            logger.info("✅ Smart Fact Checker initialized with Google Custom Search")
        
        # Simple in-memory cache (could be Redis in production)
        self._cache: Dict[str, Tuple[bool, List[SourceDetails], float]] = {}
        self._cache_ttl = timedelta(hours=24)
    
    def _extract_domain(self, url: str) -> str:
        """Extract clean domain from URL"""
        try:
            from urllib.parse import urlparse
            parsed = urlparse(url)
            domain = parsed.netloc.replace('www.', '')
            return domain
        except Exception:
            return url
    
    def _detect_authority(self, url: str) -> str:
        """
        Detect source authority level based on domain
        Returns: 'government', 'academic', 'organization', 'news', or 'general'
        """
        domain = self._extract_domain(url).lower()
        
        # Government agencies (.gov, specific agencies)
        gov_indicators = ['.gov', 'nasa', 'noaa', 'epa', 'cdc', 'nih', 'usgs', 
                         'whitehouse', 'state.gov', 'energy.gov']
        if any(indicator in domain for indicator in gov_indicators):
            return 'government'
        
        # Academic institutions (.edu, universities)
        academic_indicators = ['.edu', 'university', 'college', 'academic', 
                              'mit.edu', 'stanford', 'harvard', 'oxford', 'cambridge']
        if any(indicator in domain for indicator in academic_indicators):
            return 'academic'
        
        # International organizations
        org_indicators = ['ipcc.ch', 'who.int', 'un.org', 'wmo.int', 'worldbank.org',
                         'oecd.org', 'unesco.org', 'iaea.org']
        if any(indicator in domain for indicator in org_indicators):
            return 'organization'
        
        # Reputable news and scientific journals
        news_indicators = ['reuters.com', 'apnews.com', 'bbc.com', 'npr.org',
                          'nature.com', 'science.org', 'scientificamerican.com',
                          'nationalgeographic.com', 'smithsonianmag.com']
        if any(indicator in domain for indicator in news_indicators):
            return 'news'
        
        return 'general'
    
    async def check_facts(
        self,
        content: str,
        content_type: str,
        enable_fact_check: bool = False
    ) -> FactCheckResult:
        """
        Smart fact-checking with budget optimization
        
        Args:
            content: Content to fact-check
            content_type: Type of content
            enable_fact_check: User explicitly requested fact-checking
        
        Returns:
            FactCheckResult with verified claims
        """
        start_time = datetime.now()
        
        # Skip if not enabled or search API not configured
        if not enable_fact_check or not self.search_enabled:
            return self._get_empty_result()
        
        # Skip if content is too short (< 300 words)
        word_count = len(content.split())
        if word_count < 300:
            logger.info(f"⏭️  Skipping fact-check: content too short ({word_count} words)")
            return self._get_empty_result()
        
        try:
            # Step 1: Extract factual claims with Gemini
            logger.info("🔍 Extracting factual claims with Gemini...")
            logger.info(f"📄 Content length: {len(content)} chars, {len(content.split())} words")
            logger.info(f"📝 Content preview: {content[:300]}...")
            logger.info(f"📝 Content middle: ...{content[len(content)//2-150:len(content)//2+150]}...")
            claims = await self._extract_claims(content, content_type)
            logger.info(f"📊 Extracted {len(claims)} claims: {claims[:2] if claims else 'None'}")
            if len(claims) == 0:
                logger.warning(f"⚠️  NO CLAIMS EXTRACTED! Content may be too opinion-based or lacks verifiable facts.")
                logger.warning(f"⚠️  Content type: {content_type}, Enable check: {enable_fact_check}")
            
            if not claims:
                logger.info("✓ No verifiable factual claims found")
                return FactCheckResult(
                    checked=True,
                    claims_found=0,
                    claims_verified=0,
                    claims=[],
                    overall_confidence=1.0,
                    verification_time=(datetime.now() - start_time).total_seconds()
                )
            
            # Step 2: Select only the most important 2-3 claims to verify
            important_claims = claims[:3]  # Budget optimization!
            logger.info(f"📊 Verifying top {len(important_claims)} of {len(claims)} claims")
            
            # Step 3: Verify each claim with Google Search
            verified_claims = []
            for claim_text in important_claims:
                result = await self._verify_claim(claim_text)
                verified_claims.append(result)
            
            # Calculate overall confidence and total searches
            verified_count = sum(1 for c in verified_claims if c.verified)
            overall_confidence = verified_count / len(verified_claims) if verified_claims else 1.0
            total_searches = len(important_claims) * 5  # ~5 searches per claim (Google API default)
            
            elapsed = (datetime.now() - start_time).total_seconds()
            logger.info(f"✅ Fact-check complete: {verified_count}/{len(verified_claims)} verified in {elapsed:.2f}s")
            logger.info(f"🔍 Total Google searches used: {total_searches}")
            
            return FactCheckResult(
                checked=True,
                claims_found=len(claims),
                claims_verified=verified_count,
                claims=verified_claims,
                overall_confidence=overall_confidence,
                verification_time=elapsed,
                total_searches_used=total_searches
            )
            
        except Exception as e:
            logger.error(f"❌ Fact-checking failed: {e}")
            return self._get_empty_result()
    
    async def _extract_claims(self, content: str, content_type: str) -> List[str]:
        """Extract verifiable factual claims using Gemini"""
        
        prompt = f"""Extract ONLY the verifiable factual claims from this {content_type} content.

CONTENT:
\"\"\"
{content}
\"\"\"

INSTRUCTIONS:
- Only extract statements that are factually verifiable (numbers, dates, statistics, historical facts, scientific claims)
- Skip opinions, subjective statements, and predictions
- Skip general knowledge that doesn't need verification
- Extract maximum 5 most important claims
- Be concise and specific

Examples of GOOD claims to extract:
- "The global AI market reached $150 billion in 2023"
- "Python was created by Guido van Rossum in 1991"
- "Over 70% of Fortune 500 companies use cloud computing"

Examples of BAD claims (skip these):
- "AI is transforming industries" (too vague)
- "Python is a great language" (opinion)
- "The future of work will be remote" (prediction)

Respond with JSON array of claim strings ONLY:
["Claim 1 text here", "Claim 2 text here"]

If no verifiable claims found, return empty array: []
"""
        
        try:
            response = self.gemini_model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=512,
                    response_mime_type="application/json"
                )
            )
            
            logger.info(f"🤖 Gemini response (full): {response.text}")
            claims = json.loads(response.text)
            logger.info(f"✅ Parsed {len(claims)} claims from Gemini response")
            if len(claims) == 0:
                logger.warning(f"⚠️  Gemini returned empty array - content likely has no verifiable facts")
            return claims if isinstance(claims, list) else []
            
        except Exception as e:
            logger.error(f"❌ Claim extraction failed: {e}")
            logger.error(f"Response text: {getattr(response, 'text', 'No response')}")
            return []
    
    async def _verify_claim(self, claim: str) -> FactCheckClaim:
        """Verify a single claim using Google Custom Search with caching"""
        
        # Check cache first
        cache_key = self._get_cache_key(claim)
        if cache_key in self._cache:
            cached_verified, cached_sources, cached_confidence = self._cache[cache_key]
            logger.info(f"💾 Cache hit for claim: {claim[:50]}...")
            return FactCheckClaim(
                claim=claim,
                verified=cached_verified,
                confidence=cached_confidence,
                sources=cached_sources,
                evidence=f"Verified via {len(cached_sources)} sources" if cached_verified else "No supporting evidence found"
            )
        
        try:
            # Search Google for evidence
            search_results = self._google_search(claim)
            
            if not search_results:
                result = FactCheckClaim(
                    claim=claim,
                    verified=False,
                    confidence=0.3,
                    sources=[],
                    evidence="No search results found"
                )
            else:
                # Analyze search results with Gemini
                verified, confidence, evidence = await self._analyze_search_results(claim, search_results)
                
                # Create SourceDetails objects from top 3 search results
                sources = [
                    SourceDetails(
                        url=r['url'],
                        title=r['title'],
                        snippet=r['snippet'],
                        domain=r['domain'],
                        authority_level=r['authority_level']
                    )
                    for r in search_results[:3]
                ]
                
                result = FactCheckClaim(
                    claim=claim,
                    verified=verified,
                    confidence=confidence,
                    sources=sources,
                    evidence=evidence
                )
            
            # Cache result
            self._cache[cache_key] = (result.verified, result.sources, result.confidence)
            
            return result
            
        except Exception as e:
            logger.error(f"Claim verification failed: {e}")
            return FactCheckClaim(
                claim=claim,
                verified=False,
                confidence=0.3,
                sources=[],
                evidence=f"Verification error: {str(e)}"
            )
    
    def _google_search(self, query: str, num_results: int = 5) -> List[Dict]:
        """
        Perform Google Custom Search
        Returns structured source details with authority classification
        """
        
        try:
            url = "https://www.googleapis.com/customsearch/v1"
            params = {
                'key': self.search_api_key,
                'cx': self.search_engine_id,
                'q': query,
                'num': num_results
            }
            
            response = requests.get(url, params=params, timeout=5)
            response.raise_for_status()
            
            data = response.json()
            items = data.get('items', [])
            
            # Return structured source details with authority classification
            return [
                {
                    'url': item.get('link', ''),
                    'title': item.get('title', ''),
                    'snippet': item.get('snippet', ''),
                    'domain': self._extract_domain(item.get('link', '')),
                    'authority_level': self._detect_authority(item.get('link', ''))
                }
                for item in items
            ]
            
        except Exception as e:
            logger.error(f"Google Search failed: {e}")
            return []
    
    async def _analyze_search_results(
        self,
        claim: str,
        search_results: List[Dict]
    ) -> Tuple[bool, float, str]:
        """Use Gemini to analyze if search results support the claim"""
        
        # Prepare search evidence
        evidence_text = "\n\n".join([
            f"Source: {r['title']}\n{r['snippet']}"
            for r in search_results[:5]
        ])
        
        prompt = f"""Analyze if these search results support the factual claim.

CLAIM:
"{claim}"

SEARCH RESULTS:
{evidence_text}

TASK:
Determine if the search results SUPPORT, CONTRADICT, or are INSUFFICIENT to verify the claim.

Respond with JSON ONLY:
{{
  "verified": true,  // true if claim is supported, false if contradicted or insufficient
  "confidence": 0.85,  // 0-1 confidence in verification
  "evidence": "Brief explanation of findings"
}}
"""
        
        try:
            response = self.gemini_model.generate_content(
                prompt,
                generation_config=genai.GenerationConfig(
                    temperature=0.1,
                    max_output_tokens=256,
                    response_mime_type="application/json"
                )
            )
            
            result = json.loads(response.text)
            return (
                result.get('verified', False),
                min(max(result.get('confidence', 0.5), 0), 1),
                result.get('evidence', '')
            )
            
        except Exception as e:
            logger.error(f"Search result analysis failed: {e}")
            return (False, 0.3, "Analysis failed")
    
    def _get_cache_key(self, claim: str) -> str:
        """Generate cache key for a claim"""
        return hashlib.md5(claim.lower().encode()).hexdigest()
    
    def _get_empty_result(self) -> FactCheckResult:
        """Return empty fact-check result"""
        return FactCheckResult(
            checked=False,
            claims_found=0,
            claims_verified=0,
            claims=[],
            overall_confidence=1.0,
            verification_time=0.0
        )
