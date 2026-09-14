describe('Validación Inicial - Catálogo de Repuestos', () => {
  it('Debe cargar la página principal de Next.js correctamente', () => {
    cy.visit('/');
    cy.get('main').should('be.visible');
  });
});