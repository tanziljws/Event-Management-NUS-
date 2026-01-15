'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { ApiService } from '@/lib/api';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');
  const router = useRouter();
  const cursorRef = useRef<HTMLDivElement>(null);
  const errorTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Custom cursor
  useEffect(() => {
    const cursor = cursorRef.current;
    if (!cursor) return;

    const moveCursor = (e: MouseEvent) => {
      cursor.style.left = e.clientX + 'px';
      cursor.style.top = e.clientY + 'px';
    };

    const handleMouseEnter = (e: MouseEvent) => {
      const target = e.target as HTMLElement;
      if (target && target.classList && (target.tagName === 'BUTTON' || target.tagName === 'A' || target.classList.contains('interactive'))) {
        cursor.classList.add('hover');
      }
      if (target && (target.tagName === 'P' || target.tagName === 'H1' || target.tagName === 'H2' || target.tagName === 'H3' || target.tagName === 'INPUT')) {
        cursor.classList.add('text');
      }
    };

    const handleMouseLeave = () => {
      cursor.classList.remove('hover', 'text');
    };

    document.addEventListener('mousemove', moveCursor);
    document.addEventListener('mouseenter', handleMouseEnter);
    document.addEventListener('mouseleave', handleMouseLeave);

    return () => {
      document.removeEventListener('mousemove', moveCursor);
      document.removeEventListener('mouseenter', handleMouseEnter);
      document.removeEventListener('mouseleave', handleMouseLeave);
    };
  }, []);

  // Scroll animations
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll('.fade-in-up');
    elements.forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, []);

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (errorTimeoutRef.current) {
        clearTimeout(errorTimeoutRef.current);
      }
    };
  }, []);

  const setErrorWithTimeout = (message: string) => {
    setError(message);
    
    if (errorTimeoutRef.current) {
      clearTimeout(errorTimeoutRef.current);
    }
    
    errorTimeoutRef.current = setTimeout(() => {
      setError(null);
    }, 8000);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!email.trim()) {
      setErrorWithTimeout('Email is required');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const response = await ApiService.forgotPassword(email.trim());
      
      if (response.success) {
        setIsSuccess(true);
      } else {
        // Handle specific error cases
        if (response.code === 'USER_NOT_FOUND') {
          setErrorWithTimeout('No account found with this email address. Please check your email or create a new account.');
        } else if (response.code === 'EMAIL_NOT_VERIFIED') {
          setErrorWithTimeout('Please verify your email address before resetting your password. Check your inbox for verification instructions.');
        } else if (response.code === 'ORGANIZER_PENDING') {
          setErrorWithTimeout('Your organizer account is still pending approval. Please wait for admin verification before resetting your password.');
        } else {
          setErrorWithTimeout(response.message || 'Failed to send reset email');
        }
      }
    } catch (err: any) {
      setErrorWithTimeout(err.response?.data?.message || 'An error occurred. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (isSuccess) {
    return (
      <>
        <div ref={cursorRef} className="custom-cursor" />
        <div className="bg-grid" />
        <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>
          <div className="container" style={{ maxWidth: '500px', width: '100%' }}>
            <div className="fade-in-up">
              <Link href="/" className="interactive" style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '3rem', justifyContent: 'center' }}>
                <img
                  src="/logo-nusa.png"
                  alt="Nusa Logo"
                  style={{ 
                    height: '64px', 
                    width: 'auto', 
                    maxWidth: '100%', 
                    objectFit: 'contain',
                    maxHeight: '64px'
                  }}
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.style.display = 'none';
                    if (target.parentElement) {
                      target.parentElement.innerHTML = '<span style="font-size: 1.5rem; font-weight: 500; color: var(--color-primary)">N</span>';
                    }
                  }}
                />
                <span style={{ fontSize: '1.5rem', fontWeight: '400', color: 'var(--color-text)' }}>Nusa</span>
              </Link>

              <div style={{ 
                background: 'var(--color-bg)',
                border: '1px solid var(--border-default)',
                padding: '3rem',
                borderRadius: '1rem',
                boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
              }}>
                <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                  <div style={{
                    width: '4rem',
                    height: '4rem',
                    margin: '0 auto 1.5rem',
                    background: '#f0fdf4',
                    borderRadius: '50%',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    boxShadow: '0 4px 12px rgba(16, 185, 129, 0.2)'
                  }}>
                    <svg width="24" height="24" fill="none" stroke="#10b981" strokeWidth="2" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" d="M5 13l4 4L19 7" />
                    </svg>
                  </div>
                  
                  <div style={{ 
                    fontSize: '0.875rem', 
                    color: 'var(--color-primary)', 
                    marginBottom: '1rem',
                    fontWeight: '500',
                    letterSpacing: '0.05em',
                    textTransform: 'uppercase'
                  }}>
                    Check Your Email
                  </div>
                  
                  <h1 style={{ 
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--color-text)',
                    marginBottom: '1rem'
                  }}>
                    Reset Link Sent
                  </h1>
                  
                  <p style={{ 
                    fontSize: '1rem',
                    color: 'var(--color-muted)',
                    marginBottom: '1.5rem',
                    lineHeight: '1.6'
                  }}>
                    We've sent a password reset link to{' '}
                    <span style={{ fontWeight: '600', color: 'var(--color-primary)' }}>{email}</span>
                  </p>
                </div>

                <div style={{
                  background: 'rgba(59, 130, 246, 0.05)',
                  border: '1px solid rgba(59, 130, 246, 0.2)',
                  borderRadius: '0.75rem',
                  padding: '1.25rem',
                  marginBottom: '2rem'
                }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.75rem' }}>
                    <svg width="20" height="20" fill="none" stroke="var(--color-primary)" strokeWidth="2" viewBox="0 0 24 24" style={{ flexShrink: 0, marginTop: '0.125rem' }}>
                      <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                    </svg>
                    <div>
                      <p style={{ 
                        fontSize: '0.875rem',
                        color: 'var(--color-text)',
                        marginBottom: '0.5rem',
                        fontWeight: '500'
                      }}>
                        Check your inbox
                      </p>
                      <p style={{ 
                        fontSize: '0.875rem',
                        color: 'var(--color-muted)',
                        lineHeight: '1.5'
                      }}>
                        Please check your email inbox and click the reset link to create a new password. The link will expire in 1 hour.
                      </p>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                  <button
                    onClick={() => router.push('/login')}
                    className="btn btn-primary interactive"
                    style={{ 
                      width: '100%', 
                      justifyContent: 'center',
                      height: '3rem',
                      fontSize: '1rem',
                      fontWeight: '600'
                    }}
                  >
                    Back to Login
                  </button>
                  
                  <button
                    onClick={() => {
                      setIsSuccess(false);
                      setEmail('');
                    }}
                    className="btn btn-ghost interactive"
                    style={{ 
                      width: '100%', 
                      justifyContent: 'center',
                      height: '3rem',
                      fontSize: '0.875rem'
                    }}
                  >
                    Send Another Email
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      <div ref={cursorRef} className="custom-cursor" />
      <div className="bg-grid" />
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>
        <div className="container" style={{ maxWidth: '500px', width: '100%' }}>
          <div className="fade-in-up">
            <Link href="/" className="interactive" style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '3rem', justifyContent: 'center' }}>
              <img
                src="/logo-nusa.png"
                alt="Nusa Logo"
                style={{ 
                  height: '64px', 
                  width: 'auto', 
                  maxWidth: '100%', 
                  objectFit: 'contain',
                  maxHeight: '64px'
                }}
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.style.display = 'none';
                  if (target.parentElement) {
                    target.parentElement.innerHTML = '<span style="font-size: 1.5rem; font-weight: 500; color: var(--color-primary)">N</span>';
                  }
                }}
              />
              <span style={{ fontSize: '1.5rem', fontWeight: '400', color: 'var(--color-text)' }}>Nusa</span>
            </Link>

            <div style={{ 
              background: 'var(--color-bg)',
              border: '1px solid var(--border-default)',
              padding: '3rem',
              borderRadius: '1rem',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
            }}>
              <div style={{ textAlign: 'center', marginBottom: '2rem' }}>
                <div style={{
                  width: '4rem',
                  height: '4rem',
                  margin: '0 auto 1.5rem',
                  background: 'rgba(59, 130, 246, 0.1)',
                  borderRadius: '50%',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  <svg width="24" height="24" fill="none" stroke="var(--color-primary)" strokeWidth="2" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                  </svg>
                </div>
                
                <div style={{ 
                  fontSize: '0.875rem', 
                  color: 'var(--color-primary)', 
                  marginBottom: '1rem',
                  fontWeight: '500',
                  letterSpacing: '0.05em',
                  textTransform: 'uppercase'
                }}>
                  Forgot Password?
                </div>
                
                <h1 style={{ 
                  fontSize: '2rem',
                  fontWeight: 'bold',
                  color: 'var(--color-text)',
                  marginBottom: '1rem'
                }}>
                  Reset Your Password
                </h1>
                
                <p style={{ 
                  fontSize: '1rem',
                  color: 'var(--color-muted)',
                  marginBottom: '1.5rem',
                  lineHeight: '1.6'
                }}>
                  Enter your email address and we'll send you a link to reset your password
                </p>
              </div>

              {error && (
                <div style={{
                  background: 'linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%)',
                  border: '1px solid #fecaca',
                  color: '#dc2626',
                  padding: '1rem 1.25rem',
                  borderRadius: '0.75rem',
                  marginBottom: '2rem',
                  fontSize: '0.875rem',
                  fontWeight: '500',
                  boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
                  display: 'flex',
                  alignItems: 'flex-start',
                  justifyContent: 'space-between',
                  gap: '0.5rem',
                  animation: 'slideInDown 0.3s ease-out'
                }}>
                  <div style={{ display: 'flex', alignItems: 'flex-start', gap: '0.5rem', flex: 1 }}>
                    <svg 
                      width="16" 
                      height="16" 
                      viewBox="0 0 24 24" 
                      fill="none" 
                      stroke="currentColor" 
                      strokeWidth="2"
                      style={{ flexShrink: 0, marginTop: '0.125rem' }}
                    >
                      <circle cx="12" cy="12" r="10"/>
                      <line x1="12" y1="8" x2="12" y2="12"/>
                      <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div style={{ flex: 1 }}>
                      <span style={{ display: 'block', marginBottom: '0.5rem' }}>{error}</span>
                      {error.includes('No account found') && (
                        <Link 
                          href="/register" 
                          className="animated-link"
                          style={{ 
                            fontSize: '0.75rem',
                            color: '#dc2626',
                            textDecoration: 'underline'
                          }}
                        >
                          Create a new account instead
                        </Link>
                      )}
                      {error.includes('verify your email') && (
                        <Link 
                          href="/verify-email" 
                          className="animated-link"
                          style={{ 
                            fontSize: '0.75rem',
                            color: '#dc2626',
                            textDecoration: 'underline'
                          }}
                        >
                          Go to email verification
                        </Link>
                      )}
                    </div>
                  </div>
                  <button
                    onClick={() => setError('')}
                    style={{
                      background: 'none',
                      border: 'none',
                      color: '#dc2626',
                      cursor: 'pointer',
                      padding: '0.25rem',
                      borderRadius: '0.25rem',
                      opacity: 0.7,
                      transition: 'opacity 0.2s ease',
                      flexShrink: 0
                    }}
                    onMouseEnter={(e) => e.currentTarget.style.opacity = '1'}
                    onMouseLeave={(e) => e.currentTarget.style.opacity = '0.7'}
                  >
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <line x1="18" y1="6" x2="6" y2="18"/>
                      <line x1="6" y1="6" x2="18" y2="18"/>
                    </svg>
                  </button>
                </div>
              )}

              <form onSubmit={handleSubmit}>
                <div className="form-field">
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => {
                      setEmail(e.target.value);
                      if (error) {
                        setError('');
                      }
                    }}
                    className="form-input"
                    placeholder=" "
                    required
                    disabled={isLoading}
                  />
                  <label className="form-label">Email Address</label>
                </div>

                <button
                  type="submit"
                  disabled={isLoading || !email.trim()}
                  className="btn btn-primary interactive"
                  style={{ 
                    width: '100%', 
                    justifyContent: 'center',
                    opacity: (isLoading || !email.trim()) ? '0.7' : '1',
                    cursor: (isLoading || !email.trim()) ? 'not-allowed' : 'pointer',
                    height: '3rem',
                    fontSize: '1rem',
                    fontWeight: '600',
                    marginBottom: '2rem'
                  }}
                >
                  {isLoading ? (
                    <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                      <div style={{
                        width: '1rem',
                        height: '1rem',
                        border: '2px solid rgba(255, 255, 255, 0.3)',
                        borderTop: '2px solid white',
                        borderRadius: '50%',
                        animation: 'spin 0.8s linear infinite'
                      }} />
                      <span>Sending...</span>
                    </div>
                  ) : (
                    'Send Reset Link'
                  )}
                </button>
              </form>

              <div style={{ 
                textAlign: 'center',
                fontSize: '0.875rem',
                color: 'var(--color-muted)'
              }}>
                <Link href="/login" className="animated-link" style={{ color: 'var(--color-primary)' }}>
                  ← Back to Login
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>

      <style jsx global>{`
        :root {
          --color-bg: #ffffff;
          --color-surface: #f8f9fa;
          --color-text: #1a1a1a;
          --color-muted: #6b7280;
          --color-primary: #3b82f6;
          --border-default: #e5e7eb;
          --card-border: #d1d5db;
        }

        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
          background: var(--color-bg);
          color: var(--color-text);
          line-height: 1.6;
        }

        .custom-cursor {
          position: fixed;
          width: 20px;
          height: 20px;
          background: var(--color-primary);
          border-radius: 50%;
          pointer-events: none;
          z-index: 9999;
          transition: transform 0.1s ease;
          opacity: 0.8;
        }

        .custom-cursor.hover {
          transform: scale(1.5);
        }

        .custom-cursor.text {
          transform: scale(0.5);
        }

        .bg-grid {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background-image: 
            linear-gradient(rgba(59, 130, 246, 0.03) 1px, transparent 1px),
            linear-gradient(90deg, rgba(59, 130, 246, 0.03) 1px, transparent 1px);
          background-size: 20px 20px;
          pointer-events: none;
        }

        .fade-in-up {
          opacity: 0;
          transform: translateY(20px);
          transition: all 0.6s ease;
        }

        .fade-in-up.visible {
          opacity: 1;
          transform: translateY(0);
        }

        .form-field {
          position: relative;
          margin-bottom: 1.5rem;
        }

        .form-input {
          width: 100%;
          padding: 1rem 0;
          border: none;
          border-bottom: 1px solid var(--border-default);
          background: transparent;
          font-size: 1rem;
          outline: none;
          transition: border-color 0.3s ease;
        }

        .form-input:focus {
          border-bottom-color: var(--color-primary);
        }

        .form-input:focus + .form-label,
        .form-input:not(:placeholder-shown) + .form-label {
          transform: translateY(-1.5rem) scale(0.8);
          color: var(--color-primary);
        }

        .form-input:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .form-label {
          position: absolute;
          top: 1rem;
          left: 0;
          color: var(--color-muted);
          transition: all 0.3s ease;
          pointer-events: none;
        }

        .btn {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          padding: 0.75rem 1.5rem;
          border: none;
          border-radius: 0.5rem;
          font-size: 0.875rem;
          font-weight: 500;
          text-decoration: none;
          cursor: pointer;
          transition: all 0.3s ease;
        }

        .btn-primary {
          background: var(--color-primary);
          color: white;
        }

        .btn-primary:hover:not(:disabled) {
          background: #2563eb;
          transform: translateY(-1px);
        }

        .btn-ghost {
          background: transparent;
          color: var(--color-text);
          border: 1px solid var(--border-default);
        }

        .btn-ghost:hover:not(:disabled) {
          background: var(--color-surface);
          border-color: var(--color-primary);
        }

        .animated-link {
          text-decoration: none;
          position: relative;
          transition: color 0.3s ease;
        }

        .animated-link:hover {
          color: var(--color-primary);
        }

        .animated-link::after {
          content: '';
          position: absolute;
          bottom: -2px;
          left: 0;
          width: 0;
          height: 1px;
          background: var(--color-primary);
          transition: width 0.3s ease;
        }

        .animated-link:hover::after {
          width: 100%;
        }

        .interactive {
          transition: all 0.3s ease;
        }

        .interactive:hover {
          transform: translateY(-1px);
        }

        @keyframes slideInDown {
          from {
            opacity: 0;
            transform: translateY(-10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}</style>
    </>
  );
}
