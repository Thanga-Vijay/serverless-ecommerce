locals {
  name_prefix    = "${var.project_name}-${var.environment}"
  s3_name_prefix = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = var.owner
    },
    var.extra_tags
  )

  # DynamoDB stores only key attributes in Terraform. Non-key fields such as
  # product name, price, stock, and image URL are written by application code.
  dynamodb_tables = {
    products = {
      table_name = "products-table"
      hash_key   = "product_id"
      attributes = [
        { name = "product_id", type = "S" },
        { name = "category", type = "S" }
      ]
      global_secondary_indexes = [
        {
          name            = "category-index"
          hash_key        = "category"
          projection_type = "ALL"
        }
      ]
    }
    users = {
      table_name = "users-table"
      hash_key   = "user_id"
      attributes = [
        { name = "user_id", type = "S" },
        { name = "email", type = "S" }
      ]
      global_secondary_indexes = [
        {
          name            = "email-index"
          hash_key        = "email"
          projection_type = "ALL"
        }
      ]
    }
    cart = {
      table_name    = "cart-table"
      hash_key      = "user_id"
      range_key     = "product_id"
      ttl_attribute = "expires_at"
      attributes = [
        { name = "user_id", type = "S" },
        { name = "product_id", type = "S" }
      ]
    }
    orders = {
      table_name = "orders-table"
      hash_key   = "order_id"
      attributes = [
        { name = "order_id", type = "S" },
        { name = "user_id", type = "S" },
        { name = "order_status", type = "S" },
        { name = "created_at", type = "S" }
      ]
      global_secondary_indexes = [
        {
          name            = "user-orders-index"
          hash_key        = "user_id"
          range_key       = "created_at"
          projection_type = "ALL"
        },
        {
          name            = "order-status-index"
          hash_key        = "order_status"
          range_key       = "created_at"
          projection_type = "ALL"
        }
      ]
      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"
    }
    inventory = {
      table_name = "inventory-table"
      hash_key   = "product_id"
      attributes = [
        { name = "product_id", type = "S" }
      ]
    }
  }

  api_routes = {
    auth_signup = {
      route_key          = "POST /auth/signup"
      authorization_type = "NONE"
      service            = "auth-service"
    }
    auth_login = {
      route_key          = "POST /auth/login"
      authorization_type = "NONE"
      service            = "auth-service"
    }
    products_list = {
      route_key          = "GET /products"
      authorization_type = "JWT"
      service            = "product-service"
    }
    products_get = {
      route_key          = "GET /products/{id}"
      authorization_type = "JWT"
      service            = "product-service"
    }
    products_create = {
      route_key          = "POST /products"
      authorization_type = "JWT"
      service            = "product-service"
    }
    products_update = {
      route_key          = "PUT /products/{id}"
      authorization_type = "JWT"
      service            = "product-service"
    }
    products_delete = {
      route_key          = "DELETE /products/{id}"
      authorization_type = "JWT"
      service            = "product-service"
    }
    cart_get = {
      route_key          = "GET /cart"
      authorization_type = "JWT"
      service            = "cart-service"
    }
    cart_add_item = {
      route_key          = "POST /cart/items"
      authorization_type = "JWT"
      service            = "cart-service"
    }
    cart_delete_item = {
      route_key          = "DELETE /cart/items/{id}"
      authorization_type = "JWT"
      service            = "cart-service"
    }
    orders_create = {
      route_key          = "POST /orders"
      authorization_type = "JWT"
      service            = "order-service"
    }
    orders_get = {
      route_key          = "GET /orders/{id}"
      authorization_type = "JWT"
      service            = "order-service"
    }
    orders_user = {
      route_key          = "GET /orders/user"
      authorization_type = "JWT"
      service            = "order-service"
    }
    uploads_presigned_url = {
      route_key          = "POST /uploads/presigned-url"
      authorization_type = "JWT"
      service            = "upload-service"
    }
    admin_orders = {
      route_key          = "GET /admin/orders"
      authorization_type = "JWT"
      service            = "order-service"
    }
    admin_users = {
      route_key          = "GET /admin/users"
      authorization_type = "JWT"
      service            = "auth-service"
    }
  }

  queues = {
    order-processing-queue = {
      visibility_timeout_seconds = 60
      message_retention_seconds  = 345600
      max_receive_count          = 5
    }
    payment-processing-queue = {
      visibility_timeout_seconds = 90
      message_retention_seconds  = 345600
      max_receive_count          = 5
    }
    inventory-update-queue = {
      visibility_timeout_seconds = 60
      message_retention_seconds  = 345600
      max_receive_count          = 5
    }
    notification-queue = {
      visibility_timeout_seconds = 45
      message_retention_seconds  = 345600
      max_receive_count          = 5
    }
  }

  lambda_iam_services = {
    auth-service = {
      dynamodb_tables = ["users"]
      sqs_queues      = []
      sns_topics      = []
      s3_buckets      = []
    }
    product-service = {
      dynamodb_tables = ["products", "inventory"]
      sqs_queues      = ["inventory-update-queue"]
      sns_topics      = []
      s3_buckets      = ["product_images"]
    }
    cart-service = {
      dynamodb_tables = ["cart", "products"]
      sqs_queues      = []
      sns_topics      = []
      s3_buckets      = []
    }
    order-service = {
      dynamodb_tables = ["cart", "orders", "products", "inventory"]
      sqs_queues      = ["order-processing-queue", "payment-processing-queue", "inventory-update-queue"]
      sns_topics      = ["order-notification-topic"]
      s3_buckets      = []
    }
    payment-service = {
      dynamodb_tables = ["orders"]
      sqs_queues      = ["payment-processing-queue", "notification-queue"]
      sns_topics      = ["order-notification-topic"]
      s3_buckets      = []
    }
    inventory-service = {
      dynamodb_tables = ["inventory", "products"]
      sqs_queues      = ["inventory-update-queue"]
      sns_topics      = []
      s3_buckets      = []
    }
    notification-service = {
      dynamodb_tables = ["users", "orders"]
      sqs_queues      = ["notification-queue"]
      sns_topics      = ["order-notification-topic"]
      s3_buckets      = []
    }
    upload-service = {
      dynamodb_tables = ["products"]
      sqs_queues      = []
      sns_topics      = []
      s3_buckets      = ["product_images"]
    }
  }

  # Terraform owns runtime configuration; CI/CD owns deployed application ZIPs.
  lambda_services = {
    auth-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 15
      memory_size = 256
      environment_variables = {
        USERS_TABLE = module.dynamodb.table_names["users"]
      }
      sqs_queue_arns = []
    }
    product-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 30
      memory_size = 512
      environment_variables = {
        PRODUCTS_TABLE  = module.dynamodb.table_names["products"]
        INVENTORY_TABLE = module.dynamodb.table_names["inventory"]
        IMAGES_BUCKET   = module.s3.bucket_names["product_images"]
      }
      sqs_queue_arns = []
    }
    cart-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 20
      memory_size = 256
      environment_variables = {
        CART_TABLE     = module.dynamodb.table_names["cart"]
        PRODUCTS_TABLE = module.dynamodb.table_names["products"]
      }
      sqs_queue_arns = []
    }
    order-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 45
      memory_size = 512
      environment_variables = {
        CART_TABLE               = module.dynamodb.table_names["cart"]
        ORDERS_TABLE             = module.dynamodb.table_names["orders"]
        PAYMENT_PROCESSING_QUEUE = module.sqs.queue_urls["payment-processing-queue"]
        INVENTORY_UPDATE_QUEUE   = module.sqs.queue_urls["inventory-update-queue"]
      }
      sqs_queue_arns = []
    }
    payment-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 45
      memory_size = 512
      environment_variables = {
        ORDERS_TABLE       = module.dynamodb.table_names["orders"]
        NOTIFICATION_QUEUE = module.sqs.queue_urls["notification-queue"]
      }
      sqs_queue_arns = [module.sqs.queue_arns["payment-processing-queue"]]
    }
    inventory-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 30
      memory_size = 256
      environment_variables = {
        INVENTORY_TABLE = module.dynamodb.table_names["inventory"]
        PRODUCTS_TABLE  = module.dynamodb.table_names["products"]
      }
      sqs_queue_arns = [module.sqs.queue_arns["inventory-update-queue"]]
    }
    notification-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 30
      memory_size = 256
      environment_variables = {
        USERS_TABLE               = module.dynamodb.table_names["users"]
        ORDERS_TABLE              = module.dynamodb.table_names["orders"]
        ORDER_NOTIFICATIONS_TOPIC = module.sns.topic_arns["order-notification-topic"]
      }
      sqs_queue_arns = [module.sqs.queue_arns["notification-queue"]]
    }
    upload-service = {
      handler     = "index.handler"
      runtime     = "nodejs20.x"
      timeout     = 20
      memory_size = 256
      environment_variables = {
        IMAGES_BUCKET = module.s3.bucket_names["product_images"]
      }
      sqs_queue_arns = []
    }
  }
}
