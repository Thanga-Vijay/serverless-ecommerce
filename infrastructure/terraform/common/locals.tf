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
      service            = "order-service"
    }
    cart_add_item = {
      route_key          = "POST /cart/items"
      authorization_type = "JWT"
      service            = "order-service"
    }
    cart_delete_item = {
      route_key          = "DELETE /cart/items/{id}"
      authorization_type = "JWT"
      service            = "order-service"
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
      service            = "product-service"
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

  lambda_services = {
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
    order-service = {
      dynamodb_tables = ["cart", "orders", "products", "inventory"]
      sqs_queues      = ["order-processing-queue", "payment-processing-queue"]
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
  }
}
