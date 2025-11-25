"""
Logging Middleware & Configuration
Structured logging for the application
"""
import logging
import sys

def setup_logging():
    """Configure structured logging"""
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    
    # Remove default handlers
    logger.handlers = []
    
    # Console handler with standard formatting
    handler = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    
    return logger
