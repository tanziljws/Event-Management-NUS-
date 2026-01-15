'use client';

import React, { useRef, useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

interface OTPInputProps {
  length?: number;
  value: string;
  onChange: (value: string) => void;
  onComplete?: (value: string) => void;
  disabled?: boolean;
  error?: boolean;
  className?: string;
}

export function OTPInput({
  length = 6,
  value,
  onChange,
  onComplete,
  disabled = false,
  error = false,
  className,
}: OTPInputProps) {
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);
  const [focusedIndex, setFocusedIndex] = useState<number | null>(null);

  useEffect(() => {
    // Focus first empty input
    const firstEmptyIndex = value.length;
    if (firstEmptyIndex < length && inputRefs.current[firstEmptyIndex]) {
      inputRefs.current[firstEmptyIndex]?.focus();
    }
  }, [value, length]);

  const handleChange = (index: number, newValue: string) => {
    // Only allow digits
    if (!/^\d*$/.test(newValue)) return;

    const newOTP = value.split('');
    
    if (newValue.length > 1) {
      // Handle paste
      const pastedValue = newValue.slice(0, length - index);
      pastedValue.split('').forEach((char, i) => {
        if (index + i < length) {
          newOTP[index + i] = char;
        }
      });
    } else {
      // Handle single character input
      newOTP[index] = newValue;
    }

    const updatedOTP = newOTP.join('').slice(0, length);
    onChange(updatedOTP);

    // Move to next input
    if (newValue && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }

    // Call onComplete when all digits are filled
    if (updatedOTP.length === length && onComplete) {
      onComplete(updatedOTP);
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Backspace' && !value[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
    if (e.key === 'ArrowLeft' && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
    if (e.key === 'ArrowRight' && index < length - 1) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleFocus = (index: number) => {
    setFocusedIndex(index);
  };

  const handleBlur = () => {
    setFocusedIndex(null);
  };

  return (
    <div className={cn('flex gap-3 justify-center', className)}>
      {Array.from({ length }).map((_, index) => (
        <input
          key={index}
          ref={(el) => {
            inputRefs.current[index] = el;
          }}
          type="text"
          inputMode="numeric"
          maxLength={1}
          value={value[index] || ''}
          onChange={(e) => handleChange(index, e.target.value)}
          onKeyDown={(e) => handleKeyDown(index, e)}
          onFocus={() => handleFocus(index)}
          onBlur={handleBlur}
          disabled={disabled}
          className={cn(
            'w-14 h-16 text-center text-2xl font-semibold',
            'border-2 rounded-xl transition-all duration-200',
            'focus:outline-none focus:ring-2 focus:ring-offset-2',
            'disabled:opacity-50 disabled:cursor-not-allowed',
            error
              ? 'border-red-500 focus:border-red-500 focus:ring-red-500 bg-red-50'
              : focusedIndex === index
              ? 'border-blue-500 focus:border-blue-500 focus:ring-blue-500 bg-blue-50'
              : 'border-gray-300 focus:border-blue-500 focus:ring-blue-500 bg-white',
            'hover:border-blue-400'
          )}
        />
      ))}
    </div>
  );
}

