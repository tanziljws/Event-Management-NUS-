'use client';

import React, { useState, useEffect, useRef, Suspense } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '@/contexts/auth-context';
import { OTPInput } from '@/components/ui/otp-input';

function VerifyEmailPageContent() {
  const { verifyEmail, resendOtp, isLoading } = useAuth();
  const [email, setEmail] = useState('');
  const [emailInput, setEmailInput] = useState('');
  const [showEmailInput, setShowEmailInput] = useState(false);
  const [otp, setOtp] = useState('');
  const [countdown, setCountdown] = useState(0);
  const [canResend, setCanResend] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [hasError, setHasError] = useState(false);
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
    const emailParam = searchParams.get('email');
    if (emailParam) {
      setEmail(decodeURIComponent(emailParam));
    } else {
      // Super user mode: allow manual email input
      setShowEmailInput(true);
      // Auto-set untuk super user
      setEmailInput('imtanzil.dev');
    }
  }, [searchParams]);

  // Handle email input for super user
  const handleEmailSubmit = () => {
    if (emailInput && emailInput.includes('@')) {
      setEmail(emailInput);
      setShowEmailInput(false);
    } else {
      setError('Please enter a valid email address');
      setErrorWithTimeout('Please enter a valid email address');
    }
  };

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (countdown > 0) {
      interval = setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            setCanResend(true);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    } else {
      setCanResend(true);
    }
    return () => clearInterval(interval);
  }, [countdown]);

  const setErrorWithTimeout = (message: string) => {
    setError(message);
    setHasError(true);
    
    if (errorTimeoutRef.current) {
      clearTimeout(errorTimeoutRef.current);
    }
    
    errorTimeoutRef.current = setTimeout(() => {
      setError(null);
      setHasError(false);
    }, 5000);
  };

  const handleVerify = async () => {
    if (!email) {
      setErrorWithTimeout('Email tidak ditemukan. Silakan coba registrasi ulang.');
      return;
    }

    if (otp.length !== 6) {
      setErrorWithTimeout('Kode OTP harus 6 digit');
      return;
    }
    
    try {
      const success = await verifyEmail(email, otp);
      if (success) {
        router.push('/login?message=email-verified');
      } else {
        setErrorWithTimeout('Kode OTP tidak valid. Silakan coba lagi.');
      }
    } catch (error: any) {
      setErrorWithTimeout(error?.response?.data?.message || 'Terjadi kesalahan saat verifikasi. Silakan coba lagi.');
    }
  };

  const handleResendOTP = async () => {
    if (!canResend || !email) return;
    
    try {
      const success = await resendOtp(email);
      if (success) {
        setCanResend(false);
        setCountdown(60); // 60 seconds cooldown
        setError(null);
        setHasError(false);
      } else {
        setErrorWithTimeout('Gagal mengirim ulang OTP. Silakan coba lagi.');
      }
    } catch (error: any) {
      setErrorWithTimeout(error?.response?.data?.message || 'Gagal mengirim ulang OTP. Silakan coba lagi.');
    }
  };

  const formatTime = (seconds: number) => {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  };

  // Show email input if no email parameter (super user mode)
  if (!email && showEmailInput) {
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
                <h2 style={{ 
                  marginBottom: '2rem',
                  fontSize: '1.5rem',
                  fontWeight: '300',
                  textAlign: 'center'
                }}>
                  Masukkan Email
                </h2>

                {error && (
                  <div style={{
                    background: 'linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%)',
                    border: '1px solid #fecaca',
                    color: '#dc2626',
                    padding: '1rem 1.25rem',
                    borderRadius: '0.75rem',
                    marginBottom: '1.5rem',
                    fontSize: '0.875rem',
                    fontWeight: '500',
                    boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    gap: '0.5rem',
                    animation: 'slideInDown 0.3s ease-out'
                  }}>
                    <span>{error}</span>
                    <button
                      onClick={() => { setError(null); setHasError(false); }}
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
                    >
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <line x1="18" y1="6" x2="6" y2="18"/>
                        <line x1="6" y1="6" x2="18" y2="18"/>
                      </svg>
                    </button>
                  </div>
                )}

                <div className="form-field">
                  <input
                    type="email"
                    value={emailInput}
                    onChange={(e) => {
                      setEmailInput(e.target.value);
                      if (error) {
                        setError(null);
                        setHasError(false);
                      }
                    }}
                    onKeyPress={(e) => {
                      if (e.key === 'Enter') {
                        handleEmailSubmit();
                      }
                    }}
                    className="form-input"
                    placeholder=" "
                    required
                  />
                  <label className="form-label">Email Address</label>
                </div>

                <button
                  onClick={handleEmailSubmit}
                  disabled={!emailInput || !emailInput.includes('@')}
                  className="btn btn-primary interactive"
                  style={{ 
                    width: '100%', 
                    justifyContent: 'center',
                    opacity: (!emailInput || !emailInput.includes('@')) ? '0.7' : '1',
                    cursor: (!emailInput || !emailInput.includes('@')) ? 'not-allowed' : 'pointer'
                  }}
                >
                  Lanjutkan
                </button>

                <div style={{ 
                  textAlign: 'center',
                  fontSize: '0.875rem',
                  color: 'var(--color-muted)',
                  marginTop: '2rem'
                }}>
                  <Link href="/login" className="animated-link" style={{ color: 'var(--color-primary)' }}>
                    ← Kembali ke Login
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  // Show error only if email input was attempted but invalid
  if (!email && !showEmailInput) {
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
                Email tidak ditemukan
              </h2>
              <p style={{ color: 'var(--color-muted)', marginBottom: '2rem' }}>
                Silakan coba registrasi ulang atau kembali ke halaman login.
              </p>
              <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
                <Link href="/register">
                  <button className="btn btn-primary">Registrasi Ulang</button>
                </Link>
                <Link href="/login">
                  <button className="btn btn-ghost">Login</button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </>
    );
  }

  return (
    <>
      {/* Custom Cursor */}
      <div ref={cursorRef} className="custom-cursor" />
      
      {/* Animated Background Grid */}
      <div className="bg-grid" />

      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '2rem' }}>
        <div className="container" style={{ maxWidth: '600px', width: '100%' }}>
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
                  fontSize: '0.875rem', 
                  color: 'var(--color-primary)', 
                  marginBottom: '1rem',
                  fontWeight: '500',
                  letterSpacing: '0.05em',
                  textTransform: 'uppercase'
                }}>
                  Verify Your Email
                </div>
                
                <h1 style={{ 
                  fontSize: '2rem',
                  fontWeight: 'bold',
                  color: 'var(--color-text)',
                  marginBottom: '1rem'
                }}>
                  Enter Verification Code
                </h1>
                
                <p style={{ 
                  fontSize: '1rem',
                  color: 'var(--color-muted)',
                  marginBottom: '0.5rem'
                }}>
                  We've sent a verification code to
                </p>
                
                <p style={{ 
                  fontSize: '1rem',
                  fontWeight: '600',
                  color: 'var(--color-primary)',
                  marginBottom: '1.5rem'
                }}>
                  {email}
                </p>

                {email === 'imtanzil.dev' && (
                  <div style={{ marginBottom: '1.5rem' }}>
                    <span style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      padding: '0.375rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: '500',
                      background: '#f0fdf4',
                      color: '#166534',
                      border: '1px solid #bbf7d0'
                    }}>
                      🔓 Super User Mode
                    </span>
                  </div>
                )}
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
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flex: 1 }}>
                    <svg 
                      width="16" 
                      height="16" 
                      viewBox="0 0 24 24" 
                      fill="none" 
                      stroke="currentColor" 
                      strokeWidth="2"
                      style={{ flexShrink: 0 }}
                    >
                      <circle cx="12" cy="12" r="10"/>
                      <line x1="12" y1="8" x2="12" y2="12"/>
                      <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <span>{error}</span>
                  </div>
                  <button
                    onClick={() => { setError(null); setHasError(false); }}
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

              <div style={{ marginBottom: '2rem' }}>
                <OTPInput
                  length={6}
                  value={otp}
                  onChange={(value) => {
                    setOtp(value);
                    if (error) {
                      setError(null);
                      setHasError(false);
                    }
                  }}
                  onComplete={handleVerify}
                  disabled={isLoading}
                  error={hasError}
                />
              </div>

              <button
                onClick={handleVerify}
                disabled={isLoading || otp.length !== 6}
                className="btn btn-primary interactive"
                style={{ 
                  width: '100%', 
                  justifyContent: 'center',
                  opacity: (isLoading || otp.length !== 6) ? '0.7' : '1',
                  cursor: (isLoading || otp.length !== 6) ? 'not-allowed' : 'pointer',
                  height: '3rem',
                  fontSize: '1rem',
                  fontWeight: '600'
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
                    <span>Memverifikasi...</span>
                  </div>
                ) : (
                  'Verify Email'
                )}
              </button>

              <div style={{ 
                marginTop: '2rem',
                textAlign: 'center'
              }}>
                <p style={{ 
                  fontSize: '0.875rem',
                  color: 'var(--color-muted)',
                  marginBottom: '1rem'
                }}>
                  Didn't receive the code?
                </p>
                
                {canResend ? (
                  <button
                    onClick={handleResendOTP}
                    disabled={isLoading}
                    className="btn btn-ghost interactive"
                    style={{ 
                      fontSize: '0.875rem',
                      padding: '0.5rem 1rem',
                      opacity: isLoading ? 0.5 : 1,
                      cursor: isLoading ? 'not-allowed' : 'pointer'
                    }}
                  >
                    Resend Code
                  </button>
                ) : (
                  <p style={{ 
                    fontSize: '0.875rem',
                    color: 'var(--color-muted)'
                  }}>
                    Resend in {formatTime(countdown)}
                  </p>
                )}
              </div>

              <div style={{ 
                marginTop: '2rem',
                textAlign: 'center'
              }}>
                <Link href="/login" className="animated-link" style={{ 
                  fontSize: '0.875rem',
                  color: 'var(--color-muted)'
                }}>
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

export default function VerifyEmailPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Memuat...</p>
        </div>
      </div>
    }>
      <VerifyEmailPageContent />
    </Suspense>
  );
}

