import { createRoot } from "react-dom/client";
import { useEffect, useState } from "react";
import { Select } from "../adapters/select";

function Upgrade({ native }: { native: HTMLSelectElement }) {
  const [value, setValue] = useState(native.value);
  const [disabled, setDisabled] = useState(native.disabled);
  useEffect(() => {
    const sync = () => {
      setValue(native.value);
      setDisabled(native.disabled);
    };
    const reset = () => queueMicrotask(sync);
    const observer = new MutationObserver(sync);
    observer.observe(native, {
      attributes: true,
      attributeFilter: ["disabled"],
    });
    native.addEventListener("change", sync);
    native.addEventListener("ty:sync", sync);
    native.form?.addEventListener("reset", reset);
    return () => {
      observer.disconnect();
      native.removeEventListener("change", sync);
      native.removeEventListener("ty:sync", sync);
      native.form?.removeEventListener("reset", reset);
    };
  }, [native]);
  const options = [...native.options].map((o) => ({
    value: o.value,
    label: o.text,
    disabled: o.disabled,
  }));
  const label = document.querySelector<HTMLLabelElement>(
    `label[for="${native.id}-trigger"]`,
  );
  return (
    <Select
      id={`${native.id}-trigger`}
      label={label?.textContent ?? "请选择"}
      value={value}
      disabled={disabled}
      options={options}
      container={
        native.closest("dialog") ??
        document.querySelector<HTMLElement>(".ty-root")!
      }
      onValueChange={(next) => {
        native.value = next;
        setValue(next);
        native.dispatchEvent(new Event("change", { bubbles: true }));
      }}
    />
  );
}

function upgrade() {
for (const native of document.querySelectorAll<HTMLSelectElement>("select.ty-select:not([data-upgraded])")) {
  native.dataset.upgraded = "true";
  const host = document.createElement("div");
  host.className = "ty-select-mount";
  native.after(host);
  const label = document.querySelector<HTMLLabelElement>(
    `label[for="${native.id}"]`,
  );
  if (label) label.htmlFor = `${native.id}-trigger`;
  native.style.display = "none";
  native.tabIndex = -1;
  createRoot(host).render(<Upgrade native={native} />);
}

}
document.addEventListener("ty:upgrade", upgrade);
upgrade();
