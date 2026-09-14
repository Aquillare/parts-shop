export interface Category {
  id: string;
  name: string;
  slug: string;
  image_url: string | null;
  created_at?: string;
}

export interface Product {
  id: string;
  category_id: string;
  part_number: string;
  name: string;
  brand: string;
  price_usd: number;
  stock: number;
  images: string[];
  description: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
  categories?: Pick<Category, 'name'>;
}

export interface SupabaseApiError {
  code: string;
  details: string | null;
  hint: string | null;
  message: string;
}