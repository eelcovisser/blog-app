module lib/accesscontrol

function principal() : User {
  return securityContext.principal;
}
