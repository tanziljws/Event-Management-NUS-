'use client';

import React, { useState, useEffect, useRef, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { ApiService } from '@/lib/api';

function ResetPasswordPageContent() {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [error, setError] = useState('');
  const [token, setToken] = useState('');
  const [passwordStrength, setPasswordStrength] = useState(0);
  
  const router = useRouter();
  const searchParams = useSearchParams();
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

  useEffect(() => {
    const tokenParam = searchParams.get('token');
    if (!tokenParam) {
      setError('Invalid or missing reset token');
      return;
    }
    setToken(tokenParam);
  }, [searchParams]);

  // Password strength calculation
  useEffect(() => {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (/[A-Z]/.test(password)) strength++;
    if (/[a-z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[@$!%*?&]/.test(password)) strength++;
    setPasswordStrength(strength);
  }, [password]);

  const validatePassword = (password: string) => {
    const minLength = password.length >= 8;
    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumber = /\d/.test(password);
    const hasSpecialChar = /[@$!%*?&]/.test(password);
    
    return {
      isValid: minLength && hasUpperCase && hasLowerCase && hasNumber && hasSpecialChar,
      errors: {
        minLength: !minLength,
        hasUpperCase: !hasUpperCase,
        hasLowerCase: !hasLowerCase,
        hasNumber: !hasNumber,
        hasSpecialChar: !hasSpecialChar
      }
    };
  };

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
    
    if (!password.trim()) {
      setErrorWithTimeout('Password is required');
      return;
    }

    if (!confirmPassword.trim()) {
      setErrorWithTimeout('Please confirm your password');
      return;
    }

    if (password !== confirmPassword) {
      setErrorWithTimeout('Passwords do not match');
      return;
    }

    const validation = validatePassword(password);
    if (!validation.isValid) {
      setErrorWithTimeout('Password does not meet requirements');
      return;
    }

    setIsLoading(true);
    setError('');

    try {
      const response = await ApiService.resetPassword({
        token,
        password: password.trim()
      });
      
      if (response.success) {
        setIsSuccess(true);
      } else {
        setErrorWithTimeout(response.message || 'Failed to reset password');
      }
    } catch (err: any) {
      setErrorWithTimeout(err.response?.data?.message || 'An error occurred. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const passwordValidation = validatePassword(password);
  const getPasswordStrengthColor = () => {
    if (passwordStrength <= 2) return '#dc2626';
    if (passwordStrength <= 3) return '#f59e0b';
    return '#10b981';
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
                    Password Reset
                  </div>
                  
                  <h1 style={{ 
                    fontSize: '2rem',
                    fontWeight: 'bold',
                    color: 'var(--color-text)',
                    marginBottom: '1rem'
                  }}>
                    Successfully Reset
                  </h1>
                  
                  <p style={{ 
                    fontSize: '1rem',
                    color: 'var(--color-muted)',
                    marginBottom: '1.5rem',
                    lineHeight: '1.6'
                  }}>
                    Your password has been updated successfully. You can now log in with your new password.
                  </p>
              </div>

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
                Go to Login
                </button>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  if (!token) {
    return (
      <>
        <div ref={cursorRef} className="custom-cursor" />
        <div className="bg-grid" />
        <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>
          <div className="container" style={{ maxWidth: '500px', width: '100%' }}>
            <div className="fade-in-up" style={{
              background: 'var(--color-bg)',
              border: '1px solid var(--border-default)',
              padding: '3rem',
              borderRadius: '1rem',
              textAlign: 'center',
              boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)'
            }}>
              <div style={{ marginBottom: '1.5rem' }}>
                <svg style={{ margin: '0 auto', height: '3rem', width: '3rem', color: '#dc2626' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h2 style={{ fontSize: '1.25rem', fontWeight: '600', color: 'var(--color-text)', marginBottom: '0.5rem' }}>
                Invalid Reset Link
              </h2>
              <p style={{ color: 'var(--color-muted)', marginBottom: '2rem' }}>
                This password reset link is invalid or has expired. Please request a new password reset link.
              </p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
                <button
                  onClick={() => router.push('/login')}
                  className="btn btn-primary"
                  style={{ width: '100%' }}
                >
                  Back to Login
                </button>
                <button
                  onClick={() => router.push('/forgot-password')}
                  className="btn btn-ghost"
                  style={{ width: '100%' }}
                >
                  Request New Reset Link
                </button>
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
                    <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
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
                  Reset Password
            </div>
                
                <h1 style={{ 
                  fontSize: '2rem',
                  fontWeight: 'bold',
                  color: 'var(--color-text)',
                  marginBottom: '1rem'
                }}>
                  Create New Password
                </h1>
                
                <p style={{ 
                  fontSize: '1rem',
                  color: 'var(--color-muted)',
                  marginBottom: '1.5rem',
                  lineHeight: '1.6'
                }}>
              Enter your new password below
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
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '0.5rem',
                  animation: 'slideInDown 0.3s ease-out'
                }}>
                  <span style={{ flex: 1 }}>{error}</span>
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
                      transition: 'opacity 0.2s ease'
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
                    type={showPassword ? 'text' : 'password'}
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      if (error) {
                        setError('');
                      }
                    }}
                    className="form-input"
                    placeholder=" "
                    required
                    disabled={isLoading}
                    style={{ paddingRight: '2.5rem' }}
                  />
                  <label className="form-label">New Password</label>
                  <button
                    type="button"
                    onClick={() => setShowPassword(!showPassword)}
                    disabled={isLoading}
                    style={{
                      position: 'absolute',
                      right: '0',
                      top: '1rem',
                      background: 'none',
                      border: 'none',
                      color: 'var(--color-muted)',
                      fontSize: '0.875rem',
                      cursor: isLoading ? 'not-allowed' : 'pointer',
                      opacity: isLoading ? 0.5 : 1
                    }}
                  >
                    {showPassword ? 'Hide' : 'Show'}
                  </button>
                </div>
                
                {password && (
                  <div style={{ marginBottom: '1.5rem' }}>
                    <div style={{
                      height: '4px',
                      background: 'var(--card-border)',
                      borderRadius: '2px',
                      marginBottom: '0.75rem',
                      overflow: 'hidden'
                    }}>
                      <div style={{
                        height: '100%',
                        width: `${(passwordStrength / 5) * 100}%`,
                        background: getPasswordStrengthColor(),
                        transition: 'all 0.3s ease'
                      }} />
                    </div>
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: '1fr 1fr',
                      gap: '0.5rem',
                      fontSize: '0.75rem'
                    }}>
                      <div style={{ color: passwordValidation.errors.minLength ? '#dc2626' : '#10b981' }}>
                        {passwordValidation.errors.minLength ? '✗' : '✓'} 8+ characters
                      </div>
                      <div style={{ color: passwordValidation.errors.hasUpperCase ? '#dc2626' : '#10b981' }}>
                        {passwordValidation.errors.hasUpperCase ? '✗' : '✓'} Uppercase
                      </div>
                      <div style={{ color: passwordValidation.errors.hasLowerCase ? '#dc2626' : '#10b981' }}>
                        {passwordValidation.errors.hasLowerCase ? '✗' : '✓'} Lowercase
                    </div>
                      <div style={{ color: passwordValidation.errors.hasNumber ? '#dc2626' : '#10b981' }}>
                        {passwordValidation.errors.hasNumber ? '✗' : '✓'} Number
                    </div>
                      <div style={{ color: passwordValidation.errors.hasSpecialChar ? '#dc2626' : '#10b981', gridColumn: 'span 2' }}>
                        {passwordValidation.errors.hasSpecialChar ? '✗' : '✓'} Special char (@$!%*?&)
                    </div>
                    </div>
                  </div>
                )}

                <div className="form-field">
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => {
                      setConfirmPassword(e.target.value);
                      if (error) {
                        setError('');
                      }
                    }}
                    className="form-input"
                    placeholder=" "
                    required
                    disabled={isLoading}
                    style={{ paddingRight: '2.5rem' }}
                  />
                  <label className="form-label">Confirm New Password</label>
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                    disabled={isLoading}
                    style={{
                      position: 'absolute',
                      right: '0',
                      top: '1rem',
                      background: 'none',
                      border: 'none',
                      color: 'var(--color-muted)',
                      fontSize: '0.875rem',
                      cursor: isLoading ? 'not-allowed' : 'pointer',
                      opacity: isLoading ? 0.5 : 1
                    }}
                  >
                    {showConfirmPassword ? 'Hide' : 'Show'}
                  </button>
                </div>
                
                {confirmPassword && password !== confirmPassword && (
                  <div style={{
                    marginTop: '-1rem',
                    marginBottom: '1.5rem',
                    fontSize: '0.75rem',
                    color: '#dc2626'
                  }}>
                    ✗ Passwords do not match
                  </div>
                )}
              
                <button
                type="submit"
                disabled={isLoading || !password.trim() || !confirmPassword.trim() || !passwordValidation.isValid || password !== confirmPassword}
                  className="btn btn-primary interactive"
                  style={{ 
                    width: '100%', 
                    justifyContent: 'center',
                    opacity: (isLoading || !password.trim() || !confirmPassword.trim() || !passwordValidation.isValid || password !== confirmPassword) ? '0.7' : '1',
                    cursor: (isLoading || !password.trim() || !confirmPassword.trim() || !passwordValidation.isValid || password !== confirmPassword) ? 'not-allowed' : 'pointer',
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
                      <span>Resetting...</span>
                    </div>
                  ) : (
                    'Reset Password'
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

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Memuat...</p>
        </div>
      </div>
    }>
      <ResetPasswordPageContent />
    </Suspense>
  );
}
