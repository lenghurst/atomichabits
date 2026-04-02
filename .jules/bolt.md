## 2024-05-23 - [React Lazy with Named Exports]
**Learning:** `React.lazy` assumes `export default` by default. When lazy-loading a component that is a **named export**, the standard `lazy(() => import('./Component'))` pattern fails or crashes at runtime.
**Action:** Use the pattern `lazy(() => import('./Component').then(module => ({ default: module.NamedComponent })))` to explicitly map the named export to the `default` property expected by `React.lazy`.
