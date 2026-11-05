import * as SelectPrimitive from "@radix-ui/react-select";
import type { ComponentProps } from "react";

export type SelectOption = { value: string; label: string; disabled?: boolean };
export type SelectProps = Pick<
  ComponentProps<typeof SelectPrimitive.Root>,
  "value" | "defaultValue" | "onValueChange" | "disabled" | "required" | "name"
> & {
  id?: string;
  label: string;
  options: SelectOption[];
  placeholder?: string;
  invalid?: boolean;
  describedBy?: string;
  container?: HTMLElement;
};

// Radix owns typeahead, keyboard navigation, focus return and dismissal.
// Keep the portal in a themed host; inside native dialog use that dialog as host.
export function Select({
  id,
  label,
  options,
  placeholder = "请选择",
  invalid,
  describedBy,
  container,
  ...props
}: SelectProps) {
  return (
    <SelectPrimitive.Root {...props}>
      <SelectPrimitive.Trigger
        id={id}
        className="ty-select-trigger"
        aria-label={label}
        aria-invalid={invalid || undefined}
        aria-describedby={describedBy}
      >
        <SelectPrimitive.Value placeholder={placeholder} />
        <SelectPrimitive.Icon className="ty-select-chevron">
          <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
            <path
              d="m4.5 6.5 3.5 3.5 3.5-3.5"
              stroke="currentColor"
              strokeWidth="1.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </SelectPrimitive.Icon>
      </SelectPrimitive.Trigger>
      <SelectPrimitive.Portal container={container}>
        <SelectPrimitive.Content
          className="ty-select-content"
          position="popper"
          sideOffset={5}
          collisionPadding={12}
        >
          <SelectPrimitive.ScrollUpButton className="ty-select-scroll">
            ⌃
          </SelectPrimitive.ScrollUpButton>
          <SelectPrimitive.Viewport className="ty-select-viewport">
            {options.map((option) => (
              <SelectPrimitive.Item
                key={option.value}
                value={option.value}
                disabled={option.disabled}
                className="ty-select-item"
              >
                <SelectPrimitive.ItemText>
                  {option.label}
                </SelectPrimitive.ItemText>
                <SelectPrimitive.ItemIndicator className="ty-select-check">
                  <svg viewBox="0 0 16 16" fill="none" aria-hidden="true">
                    <path
                      d="m3.5 8 3 3 6-6"
                      stroke="currentColor"
                      strokeWidth="1.5"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </SelectPrimitive.ItemIndicator>
              </SelectPrimitive.Item>
            ))}
          </SelectPrimitive.Viewport>
          <SelectPrimitive.ScrollDownButton className="ty-select-scroll">
            ⌄
          </SelectPrimitive.ScrollDownButton>
        </SelectPrimitive.Content>
      </SelectPrimitive.Portal>
    </SelectPrimitive.Root>
  );
}
