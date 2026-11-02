import {useId, type ButtonHTMLAttributes, type InputHTMLAttributes, type HTMLAttributes} from 'react';
export function Button({variant='secondary', busy=false, children, disabled, type='button', className='', ...props}: ButtonHTMLAttributes<HTMLButtonElement> & {variant?:'primary'|'secondary'|'danger'; busy?:boolean}) {
 return <button {...props} type={type} className={`ty-button ${className}`} data-variant={variant} aria-busy={busy || undefined} disabled={disabled || busy}>{busy ? '处理中…' : children}</button>;
}
export function Card({className='', ...props}: HTMLAttributes<HTMLElement>) {
 return <section {...props} className={`ty-card ${className}`} />;
}
export function Field({label,error,id, ...props}: InputHTMLAttributes<HTMLInputElement> & {label:string; error?:string}) {
 const generated=useId(); const fieldId=id ?? generated;
 const describedBy=[props['aria-describedby'],error ? `${fieldId}-error` : undefined].filter(Boolean).join(' ') || undefined;
 return <div className="ty-stack"><label htmlFor={fieldId}>{label}</label><input {...props} className={`ty-input ${props.className ?? ''}`} id={fieldId} aria-invalid={error ? true : props['aria-invalid']} aria-describedby={describedBy}/>{error && <span id={`${fieldId}-error`} className="ty-error" role="alert">{error}</span>}</div>;
}
