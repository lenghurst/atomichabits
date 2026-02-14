export function LoadingSpinner() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-black text-white">
      <div className="h-8 w-8 animate-spin rounded-full border-2 border-white/20 border-t-white" />
    </div>
  );
}
