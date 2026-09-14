-- Eliminar la columna duplicada de productos
ALTER TABLE products DROP COLUMN IF EXISTS image_url;