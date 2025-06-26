describe('Django App Smoke Test', () => {
  it('should load the home page', () => {
    cy.visit('/')
    cy.contains('The install worked successfully! Congratulations!').should('be.visible')
  })
})