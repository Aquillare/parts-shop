import { supabase } from '@/lib/supabase';

export default async function Home() {
  // Test query to products table
  const { data, error } = await supabase.from('products').select('*');

  return (
    <main className="p-8">
      <h1 className="text-3xl font-bold mb-6">Prueba de conexión a Supabase</h1>
      
      <div className="bg-gray-100 p-4 rounded-md shadow-inner text-sm font-mono overflow-auto">
        {error ? (
          <p className="text-red-500">Error: {error.message}</p>
        ) : (
          <pre>{JSON.stringify(data, null, 2)}</pre>
        )}
      </div>
    </main>
  );
}
