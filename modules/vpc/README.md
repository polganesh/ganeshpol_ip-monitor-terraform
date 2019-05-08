This module responsible for creating
- VPC
- 3 Subnets
  - public subnet      :- Place for Load Balancers/API gateway etc.
  - private app subnet :- Place for running backend micro services
  - private DB subnet :- subnet responsible for hosting RDBMS/NoSQL
- Nat Gateway
  - Imp Note
    - responsible for Instances(EC2/Containers etc) in private subnet to communicate with Internet
    - toal number of nat gateways = number of public subnets
    - in AWS subnets dont span across multiple AZ like Azure.
  
