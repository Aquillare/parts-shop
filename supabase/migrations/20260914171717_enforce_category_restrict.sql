-- 1. Eliminar la regla anterior
ALTER TABLE products 
DROP CONSTRAINT IF EXISTS products_category_id_fkey;

-- 2. Crear la regla estricta (RESTRICT)
ALTER TABLE products 
ADD CONSTRAINT products_category_id_fkey 
FOREIGN KEY (category_id) 
REFERENCES categories (id) 
ON DELETE RESTRICT;