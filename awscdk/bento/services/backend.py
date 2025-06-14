from aws_cdk import Duration
from aws_cdk import aws_iam as iam
from aws_cdk import aws_elasticloadbalancingv2 as elbv2
from aws_cdk import aws_ecs as ecs
from aws_cdk import aws_ecr as ecr
from aws_cdk import aws_secretsmanager as secretsmanager
from aws_cdk import aws_ec2 as ec2
class backendService:
  def createService(self, config):
  #def createService(self, config, nlb):

    ### Backend Service ###############################################################################################################
    service = "backend"

    # Set container configs
    # if config.has_option(service, 'command'):
    #     command = [config[service]['command']]
    # else:
    #     command = None

    environment={
            "JAVA_OPTS": "-javaagent:/usr/local/tomcat/newrelic/newrelic.jar",
            "AUTH_ENABLED":"false",
            "AUTH_ENDPOINT":"/api/auth/",
            "BENTO_API_VERSION":config[service]['image'],
            "ES_FILTER_ENABLED":"true",
            "PROJECT":"ctdc",
            "ES_SCHEMA":"es-schema-ctdc.graphql",
            "MYSQL_SESSION_ENABLED":"true",
            #"MEMGRAPH_URL": "bolt://{}:7687".format(nlb.load_balancer_dns_name),
            "REDIS_ENABLE":"false",
            "REDIS_FILTER_ENABLE":"false",
            "REDIS_HOST":"localhost",
            "REDIS_PORT":"6379",
            "REDIS_USE_CLUSTER":"true",
            "NEW_RELIC_HOST": "gov-collector.newrelic.com",
            "NEW_RELIC_APP_NAME": "{}-{}-backend".format(config['main']['project'], config['main']['tier']),
            "NEW_RELIC_DISTRIBUTED_TRACING_ENABLED": "true",
            "NEW_RELIC_LOG_FILE_NAME":"STDOUT",
            "NEW_RELIC_LABELS":"Project:{};Environment:{}".format(config['main']['project'], config['main']['tier']),
            "JAVA_OPTS":"-javaagent:/usr/local/tomcat/newrelic/newrelic.jar",
        }

    secrets={
            "NEW_RELIC_LICENSE_KEY":ecs.Secret.from_secrets_manager(secretsmanager.Secret.from_secret_name_v2(self, "be_newrelic", secret_name='monitoring/newrelic'), 'api_key'),
            #"NEO4J_PASSWORD":ecs.Secret.from_secrets_manager(self.secret, 'neo4j_password'),
            #"NEO4J_USER":ecs.Secret.from_secrets_manager(self.secret, 'neo4j_user'),
            "ES_HOST":ecs.Secret.from_secrets_manager(self.secret, 'es_host'),
            "CLOUDFRONT_PRIVATE_KEY":ecs.Secret.from_secrets_manager(secretsmanager.Secret.from_secret_name_v2(self, "files_cf_key", secret_name="ec2-ssh-key/{}/private".format(self.cfKeys.key_pair_name)), ''),
            "CLOUDFRONT_KEY_PAIR_ID":ecs.Secret.from_secrets_manager(self.secret, 'cf_key_pair_id'),
            "CLOUDFRONT_DOMAIN":ecs.Secret.from_secrets_manager(self.secret, 'cf_url'),
            "S3_ACCESS_KEY_ID":ecs.Secret.from_secrets_manager(self.secret, 's3_access_key_id'),
            "S3_SECRET_ACCESS_KEY":ecs.Secret.from_secrets_manager(self.secret, 's3_secret_access_key'),
            "FILE_MANIFEST_BUCKET_NAME":ecs.Secret.from_secrets_manager(self.secret, 'file_manifest_bucket_name'),
        }
    
    taskDefinition = ecs.FargateTaskDefinition(self,
        "{}-{}-taskDef".format(self.namingPrefix, service),
        cpu=config.getint(service, 'taskcpu'),
        memory_limit_mib=config.getint(service, 'taskmemory')
    )

    # Grant ECR access
    taskDefinition.add_to_execution_role_policy(
            iam.PolicyStatement(
                actions=[
                    "ecr:UploadLayerPart",
                    "ecr:PutImage",
                    "ecr:ListTagsForResource",
                    "ecr:InitiateLayerUpload",
                    "ecr:GetRepositoryPolicy",
                    "ecr:GetLifecyclePolicy",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:DescribeRepositories",
                    "ecr:CompleteLayerUpload",
                    "ecr:BatchGetImage",
                    "ecr:BatchCheckLayerAvailability"
                ],
                effect=iam.Effect.ALLOW,
                resources=["arn:aws:ecr:us-east-1:986019062625:repository/*"]
            )
        )

    taskDefinition.add_to_execution_role_policy(
            iam.PolicyStatement(
                actions=["ecr:GetAuthorizationToken"],
                effect=iam.Effect.ALLOW,
                resources=["*"]
            )
        )
    
    ecr_repo = ecr.Repository.from_repository_arn(self, "{}_repo".format(service), repository_arn=config[service]['repo'])

    # Backend Container
    backend_container = taskDefinition.add_container(
        service,
        #image=ecs.ContainerImage.from_registry("{}:{}".format(config[service]['repo'], config[service]['image'])),
        image=ecs.ContainerImage.from_ecr_repository(repository=ecr_repo, tag=config[service]['image']),
        cpu=config.getint(service, 'cpu'),
        memory_limit_mib=config.getint(service, 'memory'),
        port_mappings=[ecs.PortMapping(app_protocol=ecs.AppProtocol.http, container_port=config.getint(service, 'port'), name=service)],
        #entry_point=command,
        entry_point=["sh", "-c"],
        command=[
            "wget https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip -O newrelic-java.zip && "
            "rm -rf newrelic && unzip -o newrelic-java.zip && bin/catalina.sh run"
        ],
        environment=environment,
        secrets=secrets,
        logging=ecs.LogDrivers.aws_logs(
            stream_prefix="{}-{}".format(self.namingPrefix, service)
        )
    )

    # # For Sumo Logs use
    
    # backend_container = taskDefinition.add_container(
    #     service,
    #     image=ecs.ContainerImage.from_ecr_repository(repository=ecr_repo, tag=config[service]['image']),
    #     cpu=config.getint(service, 'cpu'),
    #     memory_limit_mib=config.getint(service, 'memory'),
    #     port_mappings=[ecs.PortMapping(container_port=config.getint(service, 'port'), name=service)],
    #     command=command,
    #     environment=environment,
    #     secrets=secrets,
    #     logging=ecs.LogDrivers.firelens(
    #         options={
    #             "Name": "http",
    #             "Host": config['sumologic']['collector_endpoint'],
    #             "URI": "/receiver/v1/http/{}".format(config['sumologic']['collector_token']),
    #             "Port": "443",
    #             "tls": "on",
    #             "tls.verify": "off",
    #             "Retry_Limit": "2",
    #             "Format": "json_lines"
    #         }
    #     )
    # )


    # # Sumo Logic FireLens Log Router Container
    # sumo_logic_container = taskDefinition.add_firelens_log_router(
    #     "sumologic-firelens",
    #     image=ecs.ContainerImage.from_registry("public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"),
    #     firelens_config=ecs.FirelensConfig(
    #         type=ecs.FirelensLogRouterType.FLUENTBIT,
    #         options=ecs.FirelensOptions(
    #             enable_ecs_log_metadata=True
    #         )
    #     ),
    # essential=True
    # )

    # New Relic Container ###############################################################################################################
    new_relic_container = taskDefinition.add_container(
        "newrelic-infra",
        image=ecs.ContainerImage.from_registry("newrelic/nri-ecs:1.9.2"),
        cpu=0,
        essential=True,
        secrets={"NRIA_LICENSE_KEY":ecs.Secret.from_secrets_manager(secretsmanager.Secret.from_secret_name_v2(self, "benr_newrelic", secret_name='monitoring/newrelic'), 'api_key'),},
        environment={
            "NEW_RELIC_HOST":"gov-collector.newrelic.com",
            "NEW_RELIC_APP_NAME":"{}-{}-files".format(config['main']['project'], config['main']['tier']),
            "NRIA_IS_FORWARD_ONLY":"true",
            "NEW_RELIC_DISTRIBUTED_TRACING_ENABLED":"true",
            "NRIA_PASSTHROUGH_ENVIRONMENT":"ECS_CONTAINER_METADATA_URI,ECS_CONTAINER_METADATA_URI_V4,FARGATE",
            "FARGATE":"true",
            "NRIA_CUSTOM_ATTRIBUTES": '{"nrDeployMethod":"downloadPage"}',
            "NRIA_OVERRIDE_HOST_ROOT": ""
            },
    )

    # ECS Service ###############################################################################################################
    ecsService = ecs.FargateService(self,
        "{}-{}-service".format(self.namingPrefix, service),
        cluster=self.ECSCluster,
        task_definition=taskDefinition,
        enable_execute_command=True,
        min_healthy_percent=50,
        max_healthy_percent=200,
        circuit_breaker=ecs.DeploymentCircuitBreaker(
            enable=True,
            rollback=True
        ),
    )

    # ALB Target Group + Listener ###############################################################################################################
    ecsTarget =self.listener.add_targets("ECS-{}-Target".format(service),
        port=int(config[service]['port']),
        protocol=elbv2.ApplicationProtocol.HTTP,
        health_check = elbv2.HealthCheck(
            path=config[service]['health_check_path'],
            timeout=Duration.seconds(config.getint(service, 'health_check_timeout')),
            interval=Duration.seconds(config.getint(service, 'health_check_interval')),),
        targets=[ecsService],)

    elbv2.ApplicationListenerRule(self, id="alb-{}-rule".format(service),
        conditions=[
            elbv2.ListenerCondition.path_patterns(config[service]['path'].split(','))
        ],
        priority=int(config[service]['priority_rule_number']),
        listener=self.listener,
        target_groups=[ecsTarget])
    
    self.osDomain.connections.allow_from(ecsService, ec2.Port.HTTPS)