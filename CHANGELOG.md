# Changelog

All notable changes to this project will be documented in this file.

---


# [0.27.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.26.2...v0.27.0) (2022-10-26)


### Features

* **ELB:** add ACM certs data block and listener cert var ([#17](https://github.com/Nerdware-LLC/fixit-cloud-modules/issues/17)) ([df586b1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/df586b1395026a66737df0bb3698686de9d5a345))

## [0.26.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.26.1...v0.26.2) (2022-10-18)


### Bug Fixes

* **EventBridge:** add Event target depends_on Event rule resources ([21f2582](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/21f2582b91ea484d054f217c2c0eb880e740f3b5))

## [0.26.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.26.0...v0.26.1) (2022-10-18)


### Bug Fixes

* **Lambda:** ensure 'handler' and 'runtime' aren't provided for Image package types ([13e813c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/13e813cbc451f11fecd6aced69e6f145349b2f9b))

# [0.26.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.7...v0.26.0) (2022-10-18)


### Features

* **Lambda:** add 'should_publish' var to allow Lambda version bumps on module calls ([97c6876](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/97c6876ac45033fb3aa93f0d4e6e0799fd796640))

## [0.25.7](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.6...v0.25.7) (2022-10-18)


### Bug Fixes

* **ECR:** add brackets around flatten-fn args in repo policy resource ([78381c4](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/78381c4c87dffec1b1bef9ab2c8c871741c49f09))

## [0.25.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.5...v0.25.6) (2022-10-17)


### Bug Fixes

* **Lambda:** add 'package_type' to lambda fn resource to allow image_uri src ([85e212a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/85e212a7a6b5e9b8e425beb59062da6eeb36ec1f))

## [0.25.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.4...v0.25.5) (2022-10-17)


### Bug Fixes

* **Lambda:** correct var usage syntax in Fn+EventSrcMapping resources ([1159492](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1159492124103c2c9eda6c145c326fe0bbb9a006))

## [0.25.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.3...v0.25.4) (2022-10-17)


### Bug Fixes

* **EventBridge:** correct param type for target 'retry_policy' and 'input_transformer' ([fe071a7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fe071a74abc2d50592fb13176ab79024c0790e02))

## [0.25.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.2...v0.25.3) (2022-10-17)


### Bug Fixes

* **EventBridge:** add default values to optional vars ([d7f12cd](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d7f12cdc84a9d4c88fa68a8ed28ea83fadca61ab))

## [0.25.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.1...v0.25.2) (2022-10-13)

## [0.25.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.25.0...v0.25.1) (2022-10-13)


### Bug Fixes

* **VPC:** correct logic in NACL rule blocks from/to_port fallback to port ([cf5ff52](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cf5ff5236428cec7915a57793fb9da41dc1841ee))

# [0.25.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.24.3...v0.25.0) (2022-10-13)


### Features

* **AccountBaseline:** add multi-region default VPC comp configs to lock them down ([e4c4dfc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e4c4dfc8591df2acb24da7b50d50f83b5f0ae036))

## [0.24.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.24.2...v0.24.3) (2022-10-12)


### Bug Fixes

* **ELB:** correct for-loop value refs in lb listener rules resource ([7d82bb8](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7d82bb8b80b21e1ef333dd4bd7f267588a0c4c92))

## [0.24.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.24.1...v0.24.2) (2022-10-12)


### Bug Fixes

* **Route53:** wrap possibly-undefined 'record' property lookups in try ([0f98e2a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0f98e2aeb1fa0f48e597c550be60d13ae0381d94))

## [0.24.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.24.0...v0.24.1) (2022-10-12)


### Bug Fixes

* **Route53:** correct dynamic vpc for_each ref from 'vpc' to 'vpc_association' ([f04b989](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f04b98946e446b80ee3362172b6f947f2660f7aa))

# [0.24.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.23.0...v0.24.0) (2022-10-12)


### Features

* **Route53:** add default value to 'records' and 'delegation_sets' vars ([babc2b2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/babc2b2eb8f2d07484d60650a61c08c2fb9ef532))

# [0.23.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.22.0...v0.23.0) (2022-10-12)


### Features

* **Route53:** add option to auto-configure NS records for hosted zones ([2602ecc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2602ecc60ec9f3a30062504e9671a122d4d5e71a))

# [0.22.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.8...v0.22.0) (2022-10-11)


### Features

* **ELB:** add 'health_check' to target_groups var+resource+docs ([9cbd081](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9cbd0812b00bb8b2c1d5a4ec35c523a6649fd043))

## [0.21.8](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.7...v0.21.8) (2022-10-11)


### Bug Fixes

* **ELB:** change dynamic subnet_mapping for_each expr to use 'values(subnets)' ([e9cb27f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e9cb27fb91adf29659421e9b9ab1cde3ddb7181a))

## [0.21.7](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.6...v0.21.7) (2022-10-11)


### Bug Fixes

* **ELB:** change listener_rule refs from default_action to action ([d10bd77](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d10bd77d61f862d5ae5f10de4d8c6566fc4fc265))

## [0.21.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.5...v0.21.6) (2022-10-11)


### Bug Fixes

* **ELB:** add 'tags' arg to target_groups var, misc docs fix ([1fea56e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1fea56e1b29bd8f6a5ac8a83c1bd703e1b153c4c))
* **VPC:** replace tflint-ignore w obj key-expr parens ([53638f1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/53638f1a2ee47145ef6f9381ba3e33b1ec89cc70))

## [0.21.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.4...v0.21.5) (2022-10-11)


### Bug Fixes

* **DynamoDB:** add 'depends_on' target resources to autoscaling policies ([6871fb6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6871fb60ec43cc9bba82d63a14bd35a4c455b14e))

## [0.21.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.3...v0.21.4) (2022-10-11)


### Bug Fixes

* **DynamoDB:** correct misc syntax errors in dynamic blocks ([15418ad](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/15418ad238d5f82a6b33b70238720d8b4622a6f4))

## [0.21.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.2...v0.21.3) (2022-10-11)


### Bug Fixes

* **IAM:** add conditional-merge of 'conditions' in iam_role assumeRole policy ([01aaa0b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/01aaa0bc225b2052059a74746ddb7300c0ab76ce))

## [0.21.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.1...v0.21.2) (2022-10-11)


### Bug Fixes

* **VPC:** add tflint-ignore directive above obj w interpolated key ([28d6af0](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/28d6af045be0e3557292bb49751718e859042d80))

## [0.21.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.21.0...v0.21.1) (2022-10-11)


### Bug Fixes

* **VPC:** wrap err-causing one-fn call in RT locals with try-fn ([b2e9fd1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b2e9fd1d5366f29d5895610b3d6d24c798711503))

# [0.21.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.20.4...v0.21.0) (2022-10-11)


### Bug Fixes

* **ELB:** pluralize name of Target_Group output ([d279f23](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d279f23f200e7bade73140b52f22b05bc6aaada9))


### Features

* **ECS:** add load_balancer_config to ECS services resource+var ([2069eb5](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2069eb55f6d5d1435bcb0cc7ccc48105a75fc191))

## [0.20.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.20.3...v0.20.4) (2022-10-11)


### Bug Fixes

* **ECR:** add depends_on=repos-resource to repo-policy resource ([#15](https://github.com/Nerdware-LLC/fixit-cloud-modules/issues/15)) ([891439f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/891439fb3302becb2a08eae4150e62f1be8a009b))

## [0.20.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.20.2...v0.20.3) (2022-10-10)

## [0.20.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.20.1...v0.20.2) (2022-10-10)

## [0.20.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.20.0...v0.20.1) (2022-10-10)

# [0.20.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.19.4...v0.20.0) (2022-10-10)


### Features

* **VERSIONS:** update all module TF versions to 1.3.2; update AWS plugin to 4.34.0; update TFLint v ([041da99](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/041da9909f2f2ab5b1b0db2709675742cd3bebff))

## [0.19.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.19.3...v0.19.4) (2022-10-10)


### Bug Fixes

* **AWS-ECS:** add depends_on AppMesh Nodes resource to AppMesh route+service ([fe688d4](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fe688d40d626275f08c501ebb512b97126bab99a))
* **AWS-ECS:** ensure Task Host LTs base64 encode user_data if provided ([fd275c3](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fd275c358d127b4542ace01991c100bfdfe3f25e))

## [0.19.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.19.2...v0.19.3) (2022-10-09)


### Bug Fixes

* **AWS-ECS:** convert Task_Def.container_defs var+resource structure to obj from jsonStr ([83defed](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/83defed9d4e90bbddedbb2c2096365a95dfc1717))

## [0.19.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.19.1...v0.19.2) (2022-10-09)


### Bug Fixes

* **AWS_ECS:** correct network_config block in ecs service resource ([33e1d49](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/33e1d49d3e57a3917be9e38bdc6b0b0a51bb7746))

## [0.19.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.19.0...v0.19.1) (2022-10-09)


### Bug Fixes

* **AWS_ECS:** correct for_each iterator in task_defs resource ([bf77bc5](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/bf77bc59863a37f061ff0677878d230e10e994d6))

# [0.19.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.5...v0.19.0) (2022-10-09)


### Features

* **AWS_ECS:** add appmesh route resource,var,output ([34d964d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/34d964d2dd01982bd21918c5fc6fc8d3d35b4254))

## [0.18.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.4...v0.18.5) (2022-10-09)

## [0.18.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.3...v0.18.4) (2022-08-22)

## [0.18.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.2...v0.18.3) (2022-08-22)

## [0.18.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.1...v0.18.2) (2022-08-22)


### Bug Fixes

* **DynamoDB:** add ignore_changes r/w capacity ([c23506d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c23506d686202e3cc69da272759b2878ce8f51ac))

## [0.18.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.18.0...v0.18.1) (2022-08-21)


### Bug Fixes

* **tflint-hook:** correct tflint hook ignore regex ([d0c3d8c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d0c3d8ce97c316cf0cc2255a006774ace02384b7))

# [0.18.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.17.2...v0.18.0) (2022-08-21)


### Features

* **Lambda:** add execution role+policy resources,var,outputs ([ec2965d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ec2965d530c6fa8220fbab9eed7faec8d9274b8d))

## [0.17.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.17.1...v0.17.2) (2022-08-21)

## [0.17.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.17.0...v0.17.1) (2022-08-20)

# [0.17.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.5...v0.17.0) (2022-08-20)


### Features

* **Lambda:** add concurrency_config, perms, event_src_map, examples ([431d160](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/431d160727769bc0e15417dbbaca6d4782aa4a71))

## [0.16.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.4...v0.16.5) (2022-08-19)

## [0.16.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.3...v0.16.4) (2022-08-19)

## [0.16.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.2...v0.16.3) (2022-08-19)


### Bug Fixes

* **ECR:** rm 'resource' from ECR repo policy syntax ([54bda5c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/54bda5cfa63ed62a0f3984046df036994ada520c))

## [0.16.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.1...v0.16.2) (2022-08-18)


### Bug Fixes

* **ECR:** correct repo policy field to 'Statement' singular ([f021184](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f021184ac03ac292126832f3cb05f49fa75c3702))

## [0.16.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.16.0...v0.16.1) (2022-08-18)


### Bug Fixes

* **IAM:** wrap possible null lookup in try ([845d616](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/845d6168ba19df705a52110e0d743add34b2beb4))

# [0.16.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.15.3...v0.16.0) (2022-08-18)


### Features

* **IAM:** mv OIDC IdPs into IAM ([2a84bee](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2a84beeabb379640e216c92c08300280e0baa37e))

## [0.15.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.15.2...v0.15.3) (2022-08-18)


### Bug Fixes

* **ECR:** fix ternary-result-diff problem in repo policy data blk ([3200037](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3200037fe7286efec9a94412c23a9397e01b5066))

## [0.15.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.15.1...v0.15.2) (2022-08-18)


### Bug Fixes

* **ECR:** correct SSE arg name to 'encryption_type' ([dfa2872](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/dfa28722f8beade1b84b85914e599d8b72ef8022))

## [0.15.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.15.0...v0.15.1) (2022-08-18)

# [0.15.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.5...v0.15.0) (2022-08-18)


### Features

* **ECR:** add AWS ECR module ([#12](https://github.com/Nerdware-LLC/fixit-cloud-modules/issues/12)) ([d952f79](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d952f79e214c7a4d7821234820ce8850e21ec907))

## [0.14.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.4...v0.14.5) (2022-08-07)

## [0.14.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.3...v0.14.4) (2022-08-06)


### Bug Fixes

* **S3:** rm optional wrapper from noncurrent_days in noncurrent_exp lifecycle config ([69e8a09](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/69e8a098d1a7370b912ca44a1c302f66a4d9585b))
* **S3:** update examples to show correct usage of noncurrent_days in noncurrent_exp lifecycle config ([a4fb00b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a4fb00b80b1bdefe6ec336db141b3bd1d00a4868))

## [0.14.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.2...v0.14.3) (2022-08-06)


### Bug Fixes

* **S3:** rm num_days arg from noncurrent exp lifecycle config ([e6eb702](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e6eb70250523aff9cf213818c1b33e202ee844b3))

## [0.14.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.1...v0.14.2) (2022-08-06)


### Bug Fixes

* **S3:** correct dynamic iterator syntax; add examples ([90ef874](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/90ef874d46663c4d4307797e89cb21ac55aa97b6))

## [0.14.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.14.0...v0.14.1) (2022-08-05)


### Bug Fixes

* **ECS-Svcs:** correct network_config arg refs ([088ae99](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/088ae99699af9d45612908355e6286edab0cfc91))

# [0.14.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.6...v0.14.0) (2022-08-05)


### Features

* **AccBase:** add vars to enable stricter pw controls than CIS requires ([4d0eef7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4d0eef769b9aec73910ba4b11fdaeb3f125d6837))

## [0.13.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.5...v0.13.6) (2022-08-03)

## [0.13.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.4...v0.13.5) (2022-08-03)

## [0.13.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.3...v0.13.4) (2022-08-02)


### Bug Fixes

* **SNS:** add empty list default value to subs var ([577ecc7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/577ecc7106f23c5733effd2eafc1b83288a41433))

## [0.13.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.2...v0.13.3) (2022-08-02)

## [0.13.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.1...v0.13.2) (2022-08-01)

## [0.13.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.13.0...v0.13.1) (2022-08-01)

# [0.13.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.6...v0.13.0) (2022-08-01)


### Features

* **CloudTrail:** init add CloudTrail module ([#6](https://github.com/Nerdware-LLC/fixit-cloud-modules/issues/6)) ([48948d8](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/48948d8f94c783574567ad68306af45f06a2e8ef))

## [0.12.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.5...v0.12.6) (2022-08-01)

## [0.12.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.4...v0.12.5) (2022-08-01)

## [0.12.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.3...v0.12.4) (2022-08-01)


### Bug Fixes

* **S3:** correct output refs to old list resource names ([11e5d5d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/11e5d5d82847df5331aa3c188c3e123d1ce7f3cf))

## [0.12.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.2...v0.12.3) (2022-08-01)

## [0.12.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.1...v0.12.2) (2022-08-01)

## [0.12.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.12.0...v0.12.1) (2022-07-31)

# [0.12.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.11.1...v0.12.0) (2022-07-31)


### Bug Fixes

* **pre-commit:** disable tf-docs 'create-file-if-not-exists' setting ([fdaf699](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fdaf699ac46437bd5310152c8085d7c032099bbf))
* **tf-docs:** bring back 'Usage Examples' in tf-docs config now that hook is fixed ([91a511c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/91a511c98a2d24f6a5fe5580f0964a54eb27c83a))
* **tf-docs:** rm 'Usage Examples', messes up pre-commit hook ([aba39ae](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/aba39ae5ce176a57b89cbcac5e9bb51a896e9303))


### Features

* **Org:** add access analyzer, delegated admin, and usage examples ([a95bf44](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a95bf44f4972ba5dcfdf92dfdac91721a85ae072))
* **pre-commit:** add exclude examples to tflint hook ([858a01c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/858a01c104d38a265f69316440ce6c5b8ab9cb3d))

## [0.11.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.11.0...v0.11.1) (2022-07-29)

# [0.11.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.26...v0.11.0) (2022-07-29)


### Features

* **AWS_Lambda:** add Lambda fn vars,resource,output ([#5](https://github.com/Nerdware-LLC/fixit-cloud-modules/issues/5)) ([68086fb](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/68086fb15998777a5123bd7273c0675a0f3fd7d1))

## [0.10.26](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.25...v0.10.26) (2022-07-29)


### Bug Fixes

* **tfupdate:** bump TF required_version to 1.2.6; update READMEs ([c4f2fd7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c4f2fd7caf44d662ee09c84c89ddb0bd21ade2c2))

## [0.10.25](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.24...v0.10.25) (2022-07-27)

## [0.10.24](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.23...v0.10.24) (2022-07-27)

## [0.10.23](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.22...v0.10.23) (2022-07-27)

## [0.10.22](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.21...v0.10.22) (2022-07-27)

## [0.10.21](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.20...v0.10.21) (2022-07-27)

## [0.10.20](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.19...v0.10.20) (2022-07-27)

## [0.10.19](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.18...v0.10.19) (2022-07-27)

## [0.10.18](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.17...v0.10.18) (2022-07-26)

## [0.10.17](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.16...v0.10.17) (2022-07-26)

## [0.10.16](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.15...v0.10.16) (2022-07-26)

## [0.10.15](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.14...v0.10.15) (2022-07-26)


### Bug Fixes

* **SSO:** rm unnecessary coalesce in aws_id_store_grp ([013d93c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/013d93c804dfe7b1935a1ffc4ccce50733674f0d))

## [0.10.14](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.13...v0.10.14) (2022-07-26)

## [0.10.13](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.12...v0.10.13) (2022-07-25)


### Bug Fixes

* **ECS_Services:** wrap rolling update controls in try ([6f59408](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6f59408be3b720b94ec83db4caf96a760c317568))

## [0.10.12](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.11...v0.10.12) (2022-07-25)


### Bug Fixes

* **TaskDefs:** correct ternary types in container defs ([022db8e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/022db8ec4f11a3bbe5911819644aa9e14525c72c))

## [0.10.11](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.10...v0.10.11) (2022-07-25)


### Bug Fixes

* **MeshNodes:** correct ref to listener_port_mappings ([dd1f0f7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/dd1f0f725d5e5d0286a35d07decd69ac17d50704))

## [0.10.10](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.9...v0.10.10) (2022-07-25)


### Bug Fixes

* **MeshRouter:** set default to empty map ([3b41b1f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3b41b1fad6e9a64e85d5ff7328391ad389046c72))

## [0.10.9](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.8...v0.10.9) (2022-07-25)


### Bug Fixes

* **ECS_TaskDef:** wrap EC2 requires_compat value in set brackets ([6311d9b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6311d9bf34652ae1c0febf3383a1132dd42e80df))

## [0.10.8](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.7...v0.10.8) (2022-07-25)


### Bug Fixes

* **ECS_Cluster:** correct object refs in ECS_Cluster resources ([ef0749a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ef0749a7303b99cc337d838ddece25649e33d7a7))

## [0.10.7](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.6...v0.10.7) (2022-07-25)


### Bug Fixes

* **ECS_Cluster:** correct var.task_defs type to map of objs ([0ac612b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0ac612bce291c638f6cca734dcf57bf4ef4cd9e9))

## [0.10.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.5...v0.10.6) (2022-07-25)


### Bug Fixes

* **ECS_Cluster:** rm AppMesh route resources for refactor ([68b1069](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/68b1069173ae88c72664bd588aec774f9fd57438))

## [0.10.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.4...v0.10.5) (2022-07-25)


### Bug Fixes

* **ECS_Cluster:** make AppMesh routers+routes optional via default null ([fea20bf](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fea20bfba594a85c8f973fc2f8ecefe02cd6e559))

## [0.10.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.3...v0.10.4) (2022-07-25)


### Bug Fixes

* **VPC:** correct var validation logic ([be65f69](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/be65f691c83a9bf9f301e2c28f8ba3f7af785425))

## [0.10.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.2...v0.10.3) (2022-07-25)


### Bug Fixes

* **VPC:** fix count meta-arg in GW, rm null iterator from var.nacls ([0c8f4fa](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0c8f4fae2aaef64626e2724481ea67246f66614d))

## [0.10.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.1...v0.10.2) (2022-07-25)


### Bug Fixes

* **VPC:** replace lookup w coalesce in NACL var validation ([1f5c1f3](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1f5c1f370664a087e9929cf191c69d09bc880132))

## [0.10.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.10.0...v0.10.1) (2022-07-25)


### Bug Fixes

* **ecs_services:** make rolling_update_controls optional ([ffe5949](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ffe5949e08f9f5952116f8655524808608e88e9d))

# [0.10.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.3...v0.10.0) (2022-07-25)


### Features

* **ECS_Service:** rm old ECS Service module; update docs to reflect project change ([2ba67f7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2ba67f7132d71e9801a51b20d6ece6aa643a46fc))

## [0.9.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.3...v0.9.4) (2022-07-25)

## [0.9.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.3...v0.9.4) (2022-07-25)

## [0.9.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.2...v0.9.3) (2022-07-25)

## [0.9.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.1...v0.9.2) (2022-07-25)

## [0.9.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.9.0...v0.9.1) (2022-07-23)

# [0.9.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.8.0...v0.9.0) (2022-07-23)


### Features

* **ECS_Service:** add ECS_Service module ([07c56c1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/07c56c12c78ef0b92393f84fadab8f186ed6f7d9))
* mv incomplete modules to separate branches ([ad34355](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ad34355e9125dfa53569bdf6f6c22b4c67f0515a))

# [0.8.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.7.0...v0.8.0) (2022-07-23)


### Features

* **ECS_Service:** add ECS_Service module ([079335e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/079335e839127a0c4e7777b88f4120d935e59e61))

# [0.7.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.6.3...v0.7.0) (2022-07-22)


### Features

* **AWS_VPC:** add var.subnets params like 'type' to Subnets output obj ([926c4c2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/926c4c2f10670b9c20ca8ac3f8a09b9c11ad6c34))

## [0.6.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.6.2...v0.6.3) (2022-07-22)

## [0.6.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.6.1...v0.6.2) (2022-07-18)

## [0.6.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.6.0...v0.6.1) (2022-07-17)


### Bug Fixes

* **AWS_Config:** correct resource ref names ([19541cc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/19541ccee6b86fc76568dd52524d08784703c004))

# [0.6.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.5...v0.6.0) (2022-07-17)


### Features

* **AWS_Config:** create separate module for AWS_Config resources ([b26e175](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b26e175c3113525108eca1cd7d8c3a662c52e3b2))

## [0.5.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.4...v0.5.5) (2022-07-17)


### Bug Fixes

* **AWS_IAM:** mv policy arn lookup out of for_each to simplify applies ([2de9166](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2de9166cf7916069fb1666df90dcf70cd406a7f8))

## [0.5.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.3...v0.5.4) (2022-07-17)


### Bug Fixes

* **AWS_IAM:** add coalesce empty list in policy attchmts for role policies ([3e346fd](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3e346fd3d10ff65df19acf30969e23fa45ec53f3))

## [0.5.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.2...v0.5.3) (2022-07-17)


### Bug Fixes

* **AWS_IAM:** add default value to iam_service_linked_roles var ([1d261af](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1d261afa58634d7e275e4fcb8191a99f034f329c))

## [0.5.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.1...v0.5.2) (2022-07-17)


### Bug Fixes

* **AWS_IAM:** replace PolicyAttachment meta arg with for_each ([61621cc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/61621cc85009e62dcecac0714db1e607b8963ebd))

## [0.5.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.5.0...v0.5.1) (2022-07-17)


### Bug Fixes

* **AWS_IAM:** call sort fn on role policies to ensure consistent order ([d7c7f37](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d7c7f377fa0fcd4d857b5fa6db65bfb54a8567ed))

# [0.5.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.9...v0.5.0) (2022-07-16)


### Features

* **AWS_IAM:** add var,resource,output for Service-Linked Roles ([b1172ff](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b1172ff55f1477d2e54caee52b04a952145428a7))

## [0.4.9](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.8...v0.4.9) (2022-07-16)

## [0.4.8](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.7...v0.4.8) (2022-07-16)


### Bug Fixes

* **AWS_VPC:** correct dynamic block sets to ref value not key ([d7ce8fd](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d7ce8fd0e55549e41feef2887de4585c27d88af2))

## [0.4.7](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.6...v0.4.7) (2022-07-16)


### Bug Fixes

* **vpc-e:** correct SecGrp resource label ref ([e09fc88](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e09fc88a3d4fc1bfad4a56b0e963cea2886cd249))

## [0.4.6](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.5...v0.4.6) (2022-07-16)


### Bug Fixes

* **vpc-e:** correct ref to var.vpc_endpoints value in local ([759fa62](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/759fa62705aaaf6dd3307473a3094baa4228af28))

## [0.4.5](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.4...v0.4.5) (2022-07-16)


### Bug Fixes

* **vpc-e:** correct ref to var.vpc_endpoints key in local ([07e6fa9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/07e6fa9687ade187b5a52303872bb2d370979f06))

## [0.4.4](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.3...v0.4.4) (2022-07-15)

## [0.4.3](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.2...v0.4.3) (2022-07-15)


### Bug Fixes

* **tf-version:** bump modules TF req_version to 1.2.5 ([5b8ae83](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/5b8ae8313e5802ced48c1bc9fa5116dbfd498ddf))

## [0.4.2](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.1...v0.4.2) (2022-07-08)

## [0.4.1](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.4.0...v0.4.1) (2022-07-02)


### Bug Fixes

* **config-sns:** correct path to sns topic policy templatefile ([749c01e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/749c01e8f1580ebcadb4d6e4e553a3c6924a98fe))
* update changelogTitle so newlines are correctly interpreted ([e3ab63a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e3ab63adcf5df4f36a844483cb2c24859aa2cb66))

# [0.4.0](https://github.com/Nerdware-LLC/fixit-cloud-modules/compare/v0.3.15...v0.4.0) (2022-06-11)

### Bug Fixes

- **AccBase_KMS:** allow KMS key to attach to Org's CW Log Group ([641332e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/641332e413a0f32f606960098ffa68f1e6d506d4))
- **AccBase_KMS:** fix circular dep issue with the key's policy doc ([4093c18](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4093c18b4939b139b3b1ba7ee947e6c334609b60))
- **AccBase:** add filter to Config Recorder outputs to kill erroneous diff msg ([43eb4c0](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/43eb4c0bc5b68483dd1d3b2386e11a4f4af6a0ea))
- **AccBase:** fix output value ref to CW cross-account role (rm'd erroneous hyphen) ([cdc7622](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cdc76227e3ad96b0680de6f0d854e8c95cc7307b))
- **ACL-rules:** rm old refs to 'local.DEFAULT_PORTS' ([4dd9fd6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4dd9fd6632c05923d2fc41ee99e9be61a3f7e434))
- add coalesce fn in aws_sechub_member for_each expr ([4c46880](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4c46880f82b48a46a126927c6d5cb294373cadc2))
- add default policy_arn values for SSM and CW-Agents ([c8c073c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c8c073c3fcda89c0b19e3ec2869a03c44be6ecfd))
- add lower fn call in OIDC thumbprint_list to avoid constant-diff problem w letter casing ([79513e6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/79513e6e02d1aeb5fa12227fb83093a235d73aaa))
- add object type coercion in aws_sechub_member for_each expr ([adb9838](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/adb9838473b0ffb73c92f1aa019d5cdda4b16636))
- add try() fns where necessary ([4668bda](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4668bda8775cad2d9fb2308457e7226b04524951))
- **Alarms-SNS-Policy:** correct Sid value to have valid syntax ([1caa300](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1caa3002577f4a458be28eaa52a9fe93f8ba205d))
- **aws_iam_policy:** ensure for_each coalesces to empty obj not null ([0bf5ce1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0bf5ce1b662ab4d91ee35646b23f7854df2bd454))
- **aws_iam_role_pol_attchmt:** wrap coalesce around nullable iam_role.policy_arns ([7f45dd7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7f45dd77f490bcb2d50be935c5c1264f922aeb04))
- **AWS-Config:** ensure all accounts now create Org_Config_Role ([221b447](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/221b4476d888e5bf643955e792668867ada812fe))
- **bucket-policy:** use str interpolation to derive s3 ARNs ([85bdf54](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/85bdf5470c0fdfec7ef3517f1623b30d94a925f3))
- **CloudTrail_S3:** add condition to skip bucket policy if CloudTrail doesn't exist yet ([b141934](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b14193499fa63a3aed74fbbc1a628da6c57e36de))
- **CloudTrail_S3:** add condition to skip bucket policy if CloudTrail doesn't exist yet ([de8fabe](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/de8fabe16939e716b6cb5aa85f1a19fe8eaeb9e6))
- **CloudTrail-CloudWatch:** fix 'resources' value in CT iam policy ([03ec120](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/03ec120ccc723d183604871afc87a6af1536e9e1))
- **CloudTrail-CW:** rm refs to non-existent policy tags ([1401726](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/14017262ad1f3100b2b38babee8f298e5f63d44f))
- **CloudTrail-KMS:** correct 'resource' values in key policy ([5b7a86c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/5b7a86c64e7633f1980a30040df8f1cbece3df05))
- **CloudTrail-Logs:** change default log retention days from 365 to 400 ([58d7a99](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/58d7a99113876efb9ba9f6b0606f61c0bce9b207))
- **CloudTrail-S3:** fix 'resources' value in CT-S3 iam policy ([302e71d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/302e71dc43689c255af0e454cc32a28901af6b92))
- **CloudTrail-S3:** fix 'resources' value in CT-S3 iam policy doc ([522c25f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/522c25f3f1cb66429ed9f366681881655e237039))
- **CloudTrail-S3:** fix issues causing CloudTrail creation err ([f9a5ac8](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f9a5ac8e848823b90d40e62966ec868d292f9025))
- **CloudTrail-S3:** fix issues causing CloudTrail creation err ([cb881c3](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cb881c391e450d9a826208e6136fa3e536357d30))
- **CloudTrail:** add event selector properties to ignore_changes to kill erroneous diff msg ([c47c450](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c47c450b01a16c2da5af1f6ed8c61b4bcc5f9a77))
- **CloudTrail:** add exclude mgmt events from KMS service ([7e12458](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7e12458213ed0cf971c96103b6b18f8e9bddccda))
- **CloudTrail:** change ownership of CloudTrail's CloudWatch role to LogArchive account ([d05d5ec](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d05d5ec9f54e0bde36459341853b42af34354f88))
- **CloudTrail:** correct Org_CloudTrail CW Logs Role arn ([35d9466](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/35d94669f811dac5a8d89354272c6586e28a8d65))
- **CloudTrail:** correct ref to var org_cloudtrail_s3_bucket ([a8a7ba2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a8a7ba26395fd8325fb8b8fac1d4e3843868b7b8))
- **CloudTrail:** rm event_selector; it should only be used for data events ([5aee394](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/5aee39421db16d98773069088c9cd68f62f16fbd))
- **CloudWatch:** replace Policy Principal account IDs w account ARNs ([fb0656a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fb0656a5da2a531613889fa601206b1131bacd96))
- **Config-DC:** change s3 kms arn to use same-region key ([df92cd7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/df92cd7569153ac1defa99b9e923220dbdab3bbd))
- **Config-SNS:** add root account ARN to policy Principals ([c544743](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c544743071f10c8d785cdf392a89d6b2d58ced3d))
- **Config-SNS:** rm aggregator from policy Principal ([21fd582](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/21fd5823ddcc07289bfc3c0deabc31e085277268))
- **Config:** add 0-index to recording_group in ignore_changes ([0b8a43e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0b8a43e96ae112318e0f5442c44b59f62dc513f6))
- **Config:** add depends_on -> Org_Config_Role_Policy to policy attachment resource ([030f7a4](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/030f7a46be40b18a25e4690e96d639fad0738d6e))
- **Config:** add ignore_changes -> recording_grp.resource_types to Config Recorders ([0073d3e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0073d3eb26357d4b4c2ea9c63d1c8377fa770e09))
- **Config:** correct policy arn to include PATH ([bd4a379](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/bd4a379da5334e48006ed505e14419b1cc628b63))
- **Config:** correct policy arn to include PATH only if PATH isn't null ([11aa534](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/11aa534bd66f7ca7dcc8738c57e6d20b7dbbee87))
- **Config:** fix Org_Config_Role_Policies attachment resource ([b8a4cc7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b8a4cc7a91b37d605bbf2de237117551902cf5a3))
- **Config:** place correct region in each Delivery-Ch's KMS+SNS params ([9ea459c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9ea459c7305f758c520a4107b0357e9f2c571440))
- **Config:** place SNS Topic+Policy in each region for Config ([3da69db](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3da69dbb84b87f36cb927805fb8b5c1f89ed0058))
- **Config:** provide default str value for role policy 'path' ([d1a8282](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d1a82826dfd67f0ba225db2f933a35867c26862f))
- **ConfigRolePolicy:** create explicit dependency on policy for attachment resource ([9f4ccce](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9f4ccce6745d88a9fa07270ed3c12ca4a5c3e894))
- **Config:** update LogArchive S3 bucket policy to permit Config to PutObjectAcl ([c8163b3](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c8163b37f3dea12081e789071da2fa8bac0a6c02))
- correct reference to data.aws_caller_id properties ([6007685](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6007685d662fc72f55b9aaaf2fc86c461ee068dd))
- correct release-workflow's own path glob to ext 'yaml' not 'yml' ([c444afc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c444afcec8bf4d19c58268ab47d5a44558509c1a))
- correct release-workflow's template-files path glob ([c524bbf](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c524bbfd25ae55fa4a6006634d2ffb422b7c90b7))
- correct sec grp rules var validation; add tfsec ignore to sec grp description to stop incorrect err ([ec4a3a9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ec4a3a93443a3bb03cb9a78fdf6feddb046cfdb4))
- correct some nested var refs ([6872bdc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6872bdcdf2abd831314a43fcbbeed5ce61184668))
- correct Variables output value ref ([a095b03](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a095b03b73d875381ed883708ee84124bee911c9))
- **CW-Agent:** rm dedicated Role for CW-Agents; they'll use an exported policy ([d1e1415](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d1e1415adcf8074d0e3efd18274d664bc927752e))
- **CW-CloudTrail_Events:** update 'kms_key_id' property to point to keys ARN, not key_id as the name implies ([c9651b0](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c9651b0e1354883b0767d3f37c734da92d3da133))
- **CW-Cross_Acc:** add sort fns to lists to address constant diff issue w Principals lists ([633edc4](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/633edc4458100043910111d9ab18c45186874ed5))
- **CW-CrossAccount:** add sort to list inputs to enforce consistent input order ([fa922ab](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fa922abc8f3b60739de02c9d8f8e186aec8a8cc9))
- **gitignore:** add negation pattern for AWS_ECS_Service/local.envoy_image.tf; was being excluded via the '\*.env' pattern ([6693b4e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6693b4eab1ef069bac18ab6cd180a35634c848b1))
- **KMS-policy:** fix malformed key policy Condition ([ff77d17](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ff77d17b829b0f9dad75bd824218b9dbbc151447))
- **KMS-policy:** rm malformed SSO principal from key policy ([72b1fcb](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/72b1fcbe566c5c75ebc057873ad110abade93089))
- **Log-Archive:** rm 'aws:SourceAccount' condition key from CT GetBucketAcl statement ([8e87376](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/8e8737602314d94253971352add0450e23bf4aea))
- **Log-Archive:** swap 'ArnEquals' w 'StringEquals' in CloudTrail-write bucket policy statement ([a418609](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a4186093032cf3ddaa3d8ea31e84577a4d3735c5))
- **LogArchiveS3:** rm 'mfa_delete'; TF cant manage that setting anyway ([c5aac5f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c5aac5f5a7d7e64e9bcd4ad64b88d1d1ec305c61))
- **Org_CloudTrail_S3s:** correct dynamic logging block content ([3892425](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3892425178d6d05b41ad3abda30e2f1182820ae4))
- **Org_CloudTrail_S3s:** correct refs to S3 buckets in outputs.tf ([7098d6e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7098d6e4eeec7308853821dbec2bb0cc433fdacf))
- **Org_CloudTrail:** add data block for CloudWatch-Delivery_Role ([131a546](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/131a54655be0e647c687989d1a2d3254827c01db))
- **Org_CloudTrail:** add tfsec ignore directive on rule that erroneously keeps flagging correct usage of kms_key_id property ([6e8aff4](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6e8aff472bf4716943479ffebb04cd64aff36e97))
- **Org_CloudTrail:** ch 'kms_key_id' to ref ARN, not ID, of KMS key ([37ae77f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/37ae77f7da226ba24b840e1cf33ae98c479747dc))
- **Org_KMS:** add Allow key-policy for CloudTrail CW Log Grp ([5ff2b03](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/5ff2b0399686cfde2582fd0f258d8c05af63912a))
- **Org_KMS:** change key policy to allow key to be used by any account's CW log grp ([f1c30fd](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f1c30fd5019e6ae4e7f3feac2953d87e4e61dccc))
- **OrgAccAdminRole:** rm all SourceIp checks; TerraformCloud doesnt have reliable static IPs on this ([462e53b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/462e53b571ed2ad1e1bf71b8a2789eb1ef91a9cc))
- **OrgAccAdminRole:** update assume role policy to address auth failure issue ([7e32820](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7e32820da7f9070ad26adbe0e19423645103206a))
- point 'kms_key_id' for CT-CW LogGrp to key alias ([2d81eb5](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2d81eb5f6309ab76faa46de8b9d4cfb457dab4a6))
- **pre-commit:** rm extraneous tf_docs hook lines, we only need the one ([0fedd60](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0fedd60724023ae5c4da054751f3b80f2bf070bd))
- put s3 module back after demo ([e4de564](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e4de5646c3ea6645fac8515f8e84e37bc514071f))
- **pw-policy:** update params to meet CIS bm reqs ([a529a7d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a529a7dc5e9d0d1e59185421a158814b08a0beac))
- rm delegated_admins data source causing aws perms err ([3d5d9f5](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3d5d9f5866831c1432b0f578c9763fa694aee648))
- rm erroneous usage of 'one' fn in Config outputs ([ad6ed26](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ad6ed26ff60f93eb3c6de3406c86ae3b34df306f))
- rm underscores from OIDC IdP AssumeRole Policy 'Sid' field ([4841477](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/48414770089aa38002d7cb09f4e19a9721b2af03))
- rm unused local 'security_account_arn' ([f77e1f5](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f77e1f5157685c2d6112cc0810e64dc24d1b6408))
- **SecHub:** add ignore_changes for email+invite to fix erroneous diff issue ([468d612](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/468d6127bb1da618a7904df7b37ba50a4e01faa8))
- **SecHub:** correct for_each value refs to 'each.value' object ([b72fbd6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b72fbd6006efffba47776ce5290202341e65c5fa))
- **SecHub:** ensure only the Security account creates SecHub Aggregator resource ([8892bed](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/8892bed0c3f10e3772c0974a8c77d0a3b31bf18a))
- **SecHub:** ensure the org_admin_account resource is used by the root account, not security ([3fbb81c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3fbb81cd6ad459aaf7f2087e3e424cdb924451d3))
- **SecHub:** fix SecHub ([8385d4c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/8385d4c6daa729122062f64c51d3fb4416801d07))
- **SecHub:** switch ownership of SecHub account-memberships resource to Security account ([77a2b58](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/77a2b58de806af29416254473970509c49ebd0ff))
- set Config DelCh 's3_kms_key_arn' set to alias ARN, not alias name ([4465cef](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4465cefb365be1271761afea2279ca5f2acde437))
- **SNS-template:** wrap jsonencode in expression brackets ([42dea0d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/42dea0d9e61a0b59287b216e8811db0381f406f0))
- **subnet:** correct bool eval logic for map_public_ip param ([7355031](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7355031967aa5ba4b17d0ff9c1be6587b45d4cb4))
- **tflint:** set explicit plugin_dir ([03d47f2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/03d47f2c72fd5b429b94609ffbc753246d9eafeb))
- **tfsec:** address yml syntax errors in user_data custom check ([fbbbd25](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/fbbbd25093497398666fab8ee8abd31dceb93cf0))
- update CW Log Metric Filter ref to log grp name var ([1357a6f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/1357a6fa721a9e7e11d943daa5e861f9712ef978))
- update refs to 'CloudWatch_CIS_Alarms' SNS Topic resources ([95787e2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/95787e27cfb529949b3416ff36aef692305bf572))
- update tfsec-cache dir ignore pattern ([4326a1e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4326a1eb11e3ce117997fba0a7f2caa50487c8f9))
- **var-tags:** correct varible 'tags' type to map(string) ([6df99c9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6df99c90917cc24704a6693bdb53047aa7aa4531))
- **workspaces:** correct dynamic vcs_repo content identifier ([7097f4f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7097f4fea279d08da06db4959d69527512aadd50))

### Features

- **AccBase-VPC:** add default-vpc & related configs ([20078e3](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/20078e32653deefb465428a71f0d634f523777b3))
- **AccBase:** add account-level s3 public access block resource ([ce4b979](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ce4b9790dd3d824585f7ea443953e4965feed7e6))
- **AccBase:** add Org Access Analyzer resource/vars/output ([f61d59c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f61d59c3edc05728d41ebab708a1e05d0f39c825))
- **AccBase:** update min version info for TF and AWS plugin ([b2f705b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b2f705b17547fcad0b2e4169c249288e5ab340b6))
- **AccountBaseline:** WIP update module files ([cbad5a2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cbad5a2e13f48912a9f67315ebf6c2dac0b789b1))
- add 'assignees' to github Semantic-Release plugin ([414bac9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/414bac90355f3fccc316db4d066d6f365f983d60))
- add 'map_public_ip_on_launch' bool to subnets config ([d866b63](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d866b63307c7770eb74da694d1120bc08eebe122))
- add 'tag_names' property to workspace var and resource ([c07803e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c07803e5841312dd9596d2e2d3b6d106b878e089))
- add ARN locals for relevant accounts ([cdf55b7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cdf55b7b5d7cf978b1c6c1e01caca6d4637c1533))
- add AWS Config resources ([ca223c1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ca223c1c3ce6db9dc66d026f9e7dbf1b20531945))
- add AWS_IAM module resources, vars, outputs ([0136c63](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0136c636d6800d193f9da26989ef13a3705ab7da))
- add aws_ip_ranges data block to enable aws service cidr lookups ([5c81faf](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/5c81faf434d17bf3b13079295b9a57f861748693))
- add aws_region data block for aws service ip/cidr lookups ([d248dd2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d248dd28d9fac2594b30f2fe3499b1f4d506d7aa))
- add AWS_SecurityHub module ([c872152](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/c872152f32fa241e9764a07306215bf52f2b51e4))
- add AWS-Config regional resourcee outputs ([b6701aa](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b6701aa79506af7481cd1a0d94acaff87cb8f7b6))
- add CloudWatch Alarms resources ([cd262ed](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cd262edb700d757822d1b2e8224757e31b894f63))
- add config files for terraform-docs ([e91669e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e91669ede65e50ad32b0d7445b751a48de74cbcc))
- add config_aliases requirement for multi-region svcs like GuardDuty ([2c25dbe](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2c25dbef6f50ae323778f3ae40b6b9245538a88c))
- add containerInsights enable bool to ECS_Cluster module ([48239c7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/48239c7283d51e8141bb99e5cd0bf57f9a1b29c2))
- add cross-account CloudWatch-Agent roles, policies, outputs, and docs ([d07dbdf](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d07dbdf6323f3a256502b7b0a4809d502c574aec))
- add ec2 key-pair resource to InstanceProfile module for convenience ([507f5f0](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/507f5f00a1cb98eb3801d4299a321e8caf791ea7))
- add empty dir for upcoming Lambda module ([9365114](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/936511472909c06ba3b7e520c58a0631c5a1d53f))
- add empty module framework for upcoming new CloudFront module ([d62c14e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d62c14e745667f8a231ceef1350aee09bbf19511))
- add empty module framework for upcoming new EC2 module ([93bcf01](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/93bcf01e951ff090a1a50f739484e31f5647617d))
- add empty module framework for upcoming new KMS module ([933cd8a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/933cd8a10804225ab4d4906ef06809a9b1233ce3))
- add empty module framework for upcoming new SSO module ([9f3a7a6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9f3a7a609015ab492a99b942403a8a79e7faf44b))
- add GuardDuty module ([4e8d6c1](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/4e8d6c14a034bfbfbd5febf1cfce201dd9d27831))
- add GuardDuty resources ([95bfa26](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/95bfa2689a3fd51f7f0fe2ed6bdaec464af0e819))
- add key+alias resources, vars, and outputs ([6b4648a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6b4648ad1815c62055c8e802bf9fe97e069a93ba))
- add NACL-rule-related precondition block ([3ab63a9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3ab63a99873cf06d5144943d3ec0c633ac03e159))
- add network ACL resources file ([ecad3d7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ecad3d721b7bdde52711bc96f7672c011a3694f3))
- add new AWS_S3 module ([b371047](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b37104797ae9c575c2890f052357ef8c3df9f5e9))
- add OpenID_Connect_Providers module ([b9b1ddc](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b9b1ddc1e30741d9b4c0c03debbe7eba18deb219))
- add OrganizationAccountAccessRole to outputs ([0a0a219](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/0a0a219c14569d7159cfc6872fe6b845e9af9271))
- add outputs for newly-committed resources ([9e09f96](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9e09f961325b42b5351ad3fa91706cc1e890d372))
- add pre-commit-config ([8aee409](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/8aee40908c4a787cf590aa30ffe156d3e83a1105))
- add regional replica keys ([dbfcb2f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/dbfcb2f7f36fc42414f2f2bda1dad18f4b12f821))
- add regional resources; replace iam doc w jsonencode ([2e7fc42](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2e7fc42041a48172dc1ec297cc3969ec6037d83c))
- add SecurityHub resources ([7a3afd8](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7a3afd82cd991b0b55b08ab0c035078057514880))
- add Semantic-Release GH Action and releaserc file ([bbaca93](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/bbaca9356bbbceee8e7792bce783ab584fbd2342))
- add tags to KMS replica key resources ([b553008](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b553008bcf54dd0a3006ca691c90251c2a44e9ac))
- add TFLint config file ([812b39f](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/812b39f88a6a0358b130273f37885c58f67392a1))
- add tfsec cache dirs to gitignore ([02c26a9](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/02c26a915af72affefc439ce1312ad07fca4f49d))
- add TFSec rules dir ([d35fff7](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d35fff796e37b6027b0f10c077ab38b2b2998849))
- add tfupdate precommit hook ([d280d3c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d280d3cb83dd6a5e2614dbce0649e6f92f2c56bd))
- add vars for new resources; split old account_params into separate vars ([cfeafca](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/cfeafca6054a05468006ab9e9855d7e83d12b05e))
- add vpc endpoints to AWS_VPC module ([33a70e6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/33a70e6e1e822d956ac765b2386234d7d17bf334))
- bump aws plugin version, add non-default TF rules ([3e5a700](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3e5a70092344b09fe41fd8728e21ab967a64be9c))
- **CloudWatch:** add cross-account functionality to CW data; mv CT CW-Alarms into CT file ([db74b3c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/db74b3cd6df957ffc6eb3575fde8005b02132f43))
- **ECS_Cluster:** init commit of module README ([2096bb2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/2096bb2fc0a53d331cac179b6415f5fcb2f65cd2))
- **ECS_Cluster:** init commit of the AWS_ECS_Cluster module ([3d2673b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/3d2673b98830209a5e63791ef39a31b15bd52740))
- **ECS_Cluster:** update min version info for TF and AWS plugin ([6f500c2](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/6f500c2361652e4a6da6caa4974c641a46a3983e))
- enable TF-bin TFLint rules ([92a333e](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/92a333e66642a9e679bad5c061d923da94a581cb))
- init commit for AWS_VPC module; vpc-peering is WIP ([a65f39b](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a65f39b9477657f27f8cc4969ab2f0c7c45064fb))
- init commit of the AWS_IAM_Instance_Profile module ([f559b08](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/f559b08b00c7bf10a0e030b839922304bde64d8e))
- **InstProf:** update min version info for TF and AWS plugin ([ee40fbe](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/ee40fbeee2b64001d8835e3500e4f4758bbae778))
- **LZ:** update min version info for TF and AWS plugin ([e9105c6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/e9105c6e05c36ac6c233ce2b9ac31730207b385a))
- **NetSec:** add dir for NetSec module with initial README ([726c1a6](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/726c1a6e5d06d38f66c7ba8c32b4bb3d08e51d5d))
- **Org_CloudTrail_S3:** add access logs s3 for Org_CloudTrail's bucket ([21b94c8](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/21b94c82d3a66d74b5bc987013c555b9d4133935))
- **OrgAccessRole:** add 'aws:SourceIp' condition check to assume role policy for OrgAccountAccessRole ([88f3c5a](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/88f3c5addb010312391e30bbd36c996f93b03883))
- **pre-commit:** add 'tfsec-checkgen' hook ([d1ea9af](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/d1ea9af28fcafcc8f378dce78e1e9fa779849624))
- **pre-commit:** add tfsec pre-commit hook ([9c55370](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/9c553705f555ebd55cca7d989d35bacb25ad03f5))
- **tf-docs:** add tf_docs pre-commit hooks for all module dirs ([a31d035](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/a31d035aba892a8b500a548c50be04c05dace2e4))
- **TFC_Workspaces:** add 'terraform_version' arg to tfe_workspace.map resource ([990df81](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/990df81e19d1484401a0257417e6d3fe1735a2c1))
- **TFC_Workspaces:** update min version info for TF and TFE plugin ([abd528c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/abd528c29e9b8d80dae986325e6081f8f1fc1893))
- **tfsec:** add custom rule banning user_data cmds which may break ec2 init processes ([7679f3c](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/7679f3c72503dc74be3a9a5ddd2ebe24f3f5d5ca))
- **VPC:** bring back SecGrps resources file ([b51987d](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/b51987ddb4a07468ad1a8cfa45f527c5fba509e6))
- **VPC:** update min version info for TF and AWS plugin ([24d4647](https://github.com/Nerdware-LLC/fixit-cloud-modules/commit/24d4647f1f65f82cd0a6f50025e024ac85315c5c))
