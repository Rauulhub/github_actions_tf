LABORATORIO IMPLEMENTACION DE TERRAFORM Y GITHUB ACTIONS
Descripción:
  Se implementa codigo en terraform para desplegar VPC y EC2.
  Se configura de modo que una EC2 tenga acceso por internet mediante Internet Gw (public EC2) y la otra mediante NAT GW (private EC2), tambien se crea un S3 para guardar el tfstate
  La relación de confianza entre github y AWS no debe ser con access-key y secret access-key, debe ser con roles de IAM y usando OIDC, para esto se debe configurar previamente en AWS un identity provider y 
  un rol con accesos dependiendo de la app...https://aws.amazon.com/es/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/

  el uso de Github actions se programo para que en diferentes fases:
    fase 1: pull request se haga la verificacion del terraform init, validate
    fase 2: push se valida el plan y se despliega
    fase 3: se crea para hacer el eliminado manual
