"""
Quality Scoring System for AI-Generated Content
Evaluates content across multiple dimensions: readability, completeness, SEO, grammar
"""
import re
import logging
from typing import Dict, Any, List, Optional
from dataclasses import dataclass

logger = logging.getLogger(__name__)


@dataclass
class QualityScore:
    """Quality score breakdown"""
    overall: float  # 0.0 to 1.0
    readability: float  # Flesch-Kincaid based
    completeness: float  # Structure and length
    seo: float  # Keywords and structure
    grammar: float  # Basic grammar checks
    details: Dict[str, Any]  # Additional metrics
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            'overall': round(self.overall, 2),
            'readability': round(self.readability, 2),
            'completeness': round(self.completeness, 2),
            'seo': round(self.seo, 2),
            'grammar': round(self.grammar, 2),
            'details': self.details,
            'grade': self._get_grade()
        }
    
    def _get_grade(self) -> str:
        """Get letter grade based on overall score"""
        if self.overall >= 0.90:
            return 'A+'
        elif self.overall >= 0.80:
            return 'A'
        elif self.overall >= 0.70:
            return 'B'
        elif self.overall >= 0.60:
            return 'C'
        else:
            return 'D'


class QualityScorer:
    """
    Evaluates AI-generated content quality
    
    Scoring Formula:
    - Readability: 30% (Flesch-Kincaid)
    - Completeness: 30% (Word count, structure)
    - SEO: 20% (Keywords, headings)
    - Grammar: 20% (Basic checks)
    """
    
    # Quality thresholds
    EXCELLENT_THRESHOLD = 0.80
    GOOD_THRESHOLD = 0.70
    REGENERATE_THRESHOLD = 0.60
    
    def score_content(
        self,
        content: str,
        content_type: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> QualityScore:
        """
        Score content quality across multiple dimensions
        
        Args:
            content: The generated content text
            content_type: Type (blog, social, email, etc.)
            metadata: Additional metadata (keywords, target_length, etc.)
        
        Returns:
            QualityScore object with detailed breakdown
        """
        metadata = metadata or {}
        
        # Calculate individual scores
        readability_score = self._score_readability(content)
        completeness_score = self._score_completeness(content, content_type, metadata)
        seo_score = self._score_seo(content, metadata)
        grammar_score = self._score_grammar(content)
        
        # Calculate weighted overall score
        overall = (
            readability_score * 0.30 +
            completeness_score * 0.30 +
            seo_score * 0.20 +
            grammar_score * 0.20
        )
        
        details = {
            'word_count': self._count_words(content),
            'sentence_count': self._count_sentences(content),
            'avg_sentence_length': self._avg_sentence_length(content),
            'paragraph_count': self._count_paragraphs(content),
            'flesch_kincaid_score': self._flesch_kincaid_score(content)
        }
        
        return QualityScore(
            overall=overall,
            readability=readability_score,
            completeness=completeness_score,
            seo=seo_score,
            grammar=grammar_score,
            details=details
        )
    
    def _score_readability(self, content: str) -> float:
        """
        Score readability using Flesch-Kincaid
        
        Returns score 0.0-1.0:
        - 90-100 (0.9-1.0): Very easy to read
        - 80-90 (0.8-0.9): Easy
        - 70-80 (0.7-0.8): Fairly easy
        - 60-70 (0.6-0.7): Standard
        - Below 60 (<0.6): Difficult
        """
        fk_score = self._flesch_kincaid_score(content)
        
        # Map Flesch-Kincaid (0-100) to 0.0-1.0
        if fk_score >= 80:
            return 1.0
        elif fk_score >= 70:
            return 0.9
        elif fk_score >= 60:
            return 0.8
        elif fk_score >= 50:
            return 0.7
        elif fk_score >= 40:
            return 0.6
        else:
            return 0.5
    
    def _flesch_kincaid_score(self, content: str) -> float:
        """
        Calculate Flesch-Kincaid Readability Score
        
        Formula: 206.835 - 1.015(words/sentences) - 84.6(syllables/words)
        """
        words = self._count_words(content)
        sentences = self._count_sentences(content)
        syllables = self._count_syllables(content)
        
        if sentences == 0 or words == 0:
            return 50.0  # Default medium score
        
        words_per_sentence = words / sentences
        syllables_per_word = syllables / words
        
        score = 206.835 - (1.015 * words_per_sentence) - (84.6 * syllables_per_word)
        
        # Clamp between 0 and 100
        return max(0.0, min(100.0, score))
    
    def _score_completeness(
        self,
        content: str,
        content_type: str,
        metadata: Dict[str, Any]
    ) -> float:
        """
        Score content completeness based on structure and length
        
        Checks:
        - Word count meets target
        - Has proper structure (headings for blog, sections for email)
        - Contains required elements
        """
        score = 0.0
        word_count = self._count_words(content)
        
        # Word count check (40% of completeness)
        target_length = metadata.get('target_length', 500)
        length_ratio = min(word_count / target_length, 1.2)  # Cap at 120%
        
        if 0.8 <= length_ratio <= 1.2:
            score += 0.40  # Perfect length
        elif 0.6 <= length_ratio <= 1.4:
            score += 0.30  # Acceptable
        else:
            score += 0.20  # Too short/long
        
        # Structure check (30% of completeness)
        if content_type == 'blog':
            # Check for headings
            headings = re.findall(r'^#{1,3}\s+.+$', content, re.MULTILINE)
            if len(headings) >= 3:
                score += 0.30
            elif len(headings) >= 2:
                score += 0.20
            else:
                score += 0.10
        elif content_type == 'email':
            # Check for sections
            has_intro = bool(re.search(r'(dear|hi|hello|greetings)', content, re.IGNORECASE))
            has_cta = bool(re.search(r'(click|visit|sign up|learn more|download)', content, re.IGNORECASE))
            has_closing = bool(re.search(r'(regards|sincerely|thanks|best)', content, re.IGNORECASE))
            
            section_score = (has_intro + has_cta + has_closing) / 3 * 0.30
            score += section_score
        elif content_type == 'social':
            # Check for hashtags and engagement elements
            has_hashtags = bool(re.search(r'#\w+', content))
            has_emoji = bool(re.search(r'[\U0001F600-\U0001F64F\U0001F300-\U0001F5FF\U0001F680-\U0001F6FF\U0001F1E0-\U0001F1FF]', content))
            has_cta = bool(re.search(r'(link in bio|click|swipe|tap|check out)', content, re.IGNORECASE))
            
            engagement_score = (has_hashtags + has_emoji + has_cta) / 3 * 0.30
            score += engagement_score
        else:
            # Default structure check
            paragraphs = self._count_paragraphs(content)
            if paragraphs >= 3:
                score += 0.30
            elif paragraphs >= 2:
                score += 0.20
            else:
                score += 0.10
        
        # Content depth check (30% of completeness)
        # Check for examples, data, specifics
        has_numbers = bool(re.search(r'\d+', content))
        has_examples = bool(re.search(r'(for example|such as|like|including)', content, re.IGNORECASE))
        has_bullets = bool(re.search(r'^\s*[-*•]\s+', content, re.MULTILINE))
        
        depth_score = (has_numbers + has_examples + has_bullets) / 3 * 0.30
        score += depth_score
        
        return min(score, 1.0)
    
    def _score_seo(self, content: str, metadata: Dict[str, Any]) -> float:
        """
        Score SEO quality
        
        Checks:
        - Keywords present and naturally distributed
        - Proper heading hierarchy
        - Meta description quality (if provided)
        """
        score = 0.0
        keywords = metadata.get('keywords', [])
        content_lower = content.lower()
        
        if not keywords:
            return 0.7  # Default if no keywords provided
        
        # Keyword presence (40% of SEO)
        keyword_count = 0
        for keyword in keywords:
            if keyword.lower() in content_lower:
                keyword_count += 1
        
        keyword_ratio = keyword_count / len(keywords) if keywords else 0
        score += keyword_ratio * 0.40
        
        # Keyword density (30% of SEO) - should be 1-3%
        total_words = self._count_words(content)
        if total_words > 0:
            total_keyword_occurrences = sum(
                content_lower.count(kw.lower()) for kw in keywords
            )
            density = (total_keyword_occurrences / total_words) * 100
            
            if 1.0 <= density <= 3.0:
                score += 0.30  # Ideal density
            elif 0.5 <= density <= 4.0:
                score += 0.20  # Acceptable
            else:
                score += 0.10  # Too low or too high
        
        # Heading structure (30% of SEO)
        headings = re.findall(r'^#{1,3}\s+.+$', content, re.MULTILINE)
        if len(headings) >= 3:
            # Check if primary keyword in first heading
            if headings and keywords and any(kw.lower() in headings[0].lower() for kw in keywords):
                score += 0.30
            else:
                score += 0.20
        elif len(headings) >= 1:
            score += 0.15
        
        return min(score, 1.0)
    
    def _score_grammar(self, content: str) -> float:
        """
        Score grammar quality (basic checks)
        
        Checks:
        - Capitalization
        - Punctuation
        - Common errors
        """
        score = 1.0  # Start perfect, deduct for issues
        issues = 0
        
        # Check for capitalization after periods
        sentences = re.split(r'[.!?]+\s+', content)
        for sentence in sentences:
            if sentence and not sentence[0].isupper():
                issues += 1
        
        # Check for double spaces
        if '  ' in content:
            issues += 1
        
        # Check for missing punctuation at end
        if content and content[-1] not in '.!?':
            issues += 1
        
        # Check for common errors
        common_errors = [
            r'\bi\s',  # lowercase 'i'
            r'\s{2,}',  # multiple spaces
            r'[.!?]{2,}',  # repeated punctuation
        ]
        
        for pattern in common_errors:
            if re.search(pattern, content):
                issues += 1
        
        # Deduct 0.05 per issue, minimum 0.5
        score = max(0.5, score - (issues * 0.05))
        
        return score
    
    # Helper methods
    
    def _count_words(self, text: str) -> int:
        """Count words in text"""
        return len(re.findall(r'\b\w+\b', text))
    
    def _count_sentences(self, text: str) -> int:
        """Count sentences in text"""
        return len(re.split(r'[.!?]+', text.strip())) - 1 or 1
    
    def _count_paragraphs(self, text: str) -> int:
        """Count paragraphs (double newline separated)"""
        return len([p for p in text.split('\n\n') if p.strip()])
    
    def _avg_sentence_length(self, text: str) -> float:
        """Calculate average words per sentence"""
        words = self._count_words(text)
        sentences = self._count_sentences(text)
        return round(words / sentences, 1) if sentences > 0 else 0.0
    
    def _count_syllables(self, text: str) -> int:
        """
        Estimate syllable count
        Simple heuristic: count vowel groups
        """
        text = text.lower()
        syllables = 0
        vowels = 'aeiouy'
        previous_was_vowel = False
        
        for char in text:
            is_vowel = char in vowels
            if is_vowel and not previous_was_vowel:
                syllables += 1
            previous_was_vowel = is_vowel
        
        # Adjust for silent e
        if text.endswith('e'):
            syllables -= 1
        
        # Ensure at least 1 syllable per word
        words = self._count_words(text)
        return max(syllables, words)
    
    def should_regenerate(self, quality_score: QualityScore) -> bool:
        """
        Determine if content should be regenerated
        
        Regenerate if:
        - Overall score < 0.60 (D grade)
        - Readability < 0.50 (too difficult)
        - Completeness < 0.60 (incomplete)
        """
        return (
            quality_score.overall < self.REGENERATE_THRESHOLD or
            quality_score.readability < 0.50 or
            quality_score.completeness < 0.60
        )
    
    def get_improvement_suggestions(self, quality_score: QualityScore) -> List[str]:
        """
        Generate improvement suggestions based on scores
        """
        suggestions = []
        
        if quality_score.readability < 0.70:
            suggestions.append("📖 Improve readability: Use shorter sentences and simpler words")
        
        if quality_score.completeness < 0.70:
            suggestions.append("📝 Add more content: Include more details, examples, or sections")
        
        if quality_score.seo < 0.70:
            suggestions.append("🔍 Enhance SEO: Include more keywords naturally and add headings")
        
        if quality_score.grammar < 0.80:
            suggestions.append("✏️ Fix grammar: Check capitalization, punctuation, and spacing")
        
        if quality_score.overall >= 0.80:
            suggestions.append("✅ Excellent quality! Content is ready to publish")
        
        return suggestions


# Global quality scorer instance
quality_scorer = QualityScorer()
