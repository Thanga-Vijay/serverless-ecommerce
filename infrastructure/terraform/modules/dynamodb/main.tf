resource "aws_dynamodb_table" "this" {
  for_each = var.tables

  name         = "${var.name_prefix}-${each.value.table_name}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = each.value.hash_key
  range_key    = each.value.range_key

  dynamic "attribute" {
    for_each = each.value.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
    }
  }

  dynamic "ttl" {
    for_each = each.value.ttl_attribute == null ? [] : [each.value.ttl_attribute]
    content {
      attribute_name = ttl.value
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = each.value.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled = true
  }

  stream_enabled   = each.value.stream_enabled
  stream_view_type = each.value.stream_view_type

  deletion_protection_enabled = each.value.deletion_protection_enabled

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value.table_name}"
  })
}
