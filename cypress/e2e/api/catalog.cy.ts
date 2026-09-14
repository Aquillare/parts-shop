import { Product, SupabaseApiError } from '../../support/types/api';


describe('API Integration - Catalog & Integrity Tests', () => {

  let SUPABASE_URL: string;
  let ANON_KEY: string;
  let SERVICE_ROLE_KEY: string;

  let adminHeaders: Record<string, string>; 

  before(() => {
    cy.env(['SUPABASE_URL','ANON_KEY','SERVICE_ROLE_KEY']).then(({ SUPABASE_URL: url, ANON_KEY: anonKey, SERVICE_ROLE_KEY: serviceRoleKey }) => {
      SUPABASE_URL = url as string;
      ANON_KEY = anonKey as string;
      SERVICE_ROLE_KEY = serviceRoleKey as string;

      cy.task('log', `URL leída: ${SUPABASE_URL}`);
      cy.task('log', `¿Tiene ANON KEY?: ${!!ANON_KEY}`);

      adminHeaders = {
        apikey: SERVICE_ROLE_KEY,
        Authorization: `Bearer ${SERVICE_ROLE_KEY}`,
        'Content-Type': 'application/json',
        Prefer: 'return=representation',
      };

    })
  })

  it('GET: Should fetch products with joined category name', () => {
    cy.request<Product[]>({
      method: 'GET',
      url: `${SUPABASE_URL}/products?select=*,categories(name)`,
      headers: {
        apikey: ANON_KEY,
      },
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.be.an('array');
      expect(response.body.length).to.be.greaterThan(0);

      const firstProduct = response.body[0];
      expect(firstProduct).to.have.property('part_number');
      expect(firstProduct.images).to.be.an('array');
      
      if (firstProduct.categories) {
        expect(firstProduct.categories).to.have.property('name');
      }
    });
  });

  it('PATCH: Should update product images array', () => {
    const newImageUrl = 'https://szujycvyzazjekmziilp.supabase.co/storage/v1/object/public/catalog/products/bujia-ngk.jpg';

    cy.request<Product[]>({
      method: 'PATCH',
      url: `${SUPABASE_URL}/products?part_number=eq.BKR6E-11`,
      headers: adminHeaders,
      body: {
        images: [newImageUrl],
      },
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body[0].images).to.include(newImageUrl);
    });
  });

  it('DELETE (Negative Test): Should reject deleting category with attached products', () => {
    cy.request<SupabaseApiError>({
      method: 'DELETE',
      url: `${SUPABASE_URL}/categories?slug=eq.bujias`,
      headers: adminHeaders,
      failOnStatusCode: false, // Prevents Cypress from failing on 4xx/5xx responses
    }).then((response) => {
      // PostgREST returns 409 Conflict for foreign key constraint violations
      cy.task('log', `DELETE Response: ${response}`);
      expect(response.status).to.eq(409);
      expect(response.body.message).to.include('violates foreign key constraint');
      expect(response.body.code).to.eq('23503'); // PostgreSQL code for foreign key violation
    });
  });
});