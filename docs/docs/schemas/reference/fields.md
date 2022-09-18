---
title: Schema fields
description: Schema fields reference.
---

This page provides a reference for all the available field options and field types that can be used when defining schemas.

## Common field options

The following field options can be used for all the available field types when declaring schema fields using the `field` macro.

### `required`

The `required` argument can be used to specify that a schema field is required or not required. The default value for this argument is `true`.

## Field types

### `bool`

A `bool` field allows to validate boolean values.

### `date_time`

A `date_time` field allows to validate date time values. Fields using this type are converted to `Time` objects in Crystal.

### `date`

A `date` field allows to validate date values. Fields using this type are converted to `Time` objects in Crystal.

### `file`

A `file` fields allows to validate uploaded files. In addition to the [common field options](#common-field-options), such fields support the following arguments:

#### `allow_empty_files`

The `allow_empty_files` argument allows to define whether empty files are allowed or not when files are validated. The default value is `false`.

#### `max_name_size`

The `max_name_size` argument allows to define the maximum file name size allowed. The default value is `nil`, which means that uploaded file name sizes are not validated.

### `float`

A `float` field allows to validate float values. Fields using this type are converted to `Float64` objects in Crystal. In addition to the [common field options](#common-field-options), such fields support the following arguments:

#### `max_value`

The `max_value` argument allows to define the maximum value allowed. The default value for this argument is `nil`, which means that the maximum value is not validated by default.

#### `min_value`

The `min_value` argument allows to define the minimum value allowed. The default value for this argument is `nil`, which means that the minimum value is not validated by default.

### `int`

An `int` field allows to validate integer values. Fields using this type are converted to `Int64` objects in Crystal. In addition to the [common field options](#common-field-options), such fields support the following arguments:

#### `max_value`

The `max_value` argument allows to define the maximum value allowed. The default value for this argument is `nil`, which means that the maximum value is not validated by default.

#### `min_value`

The `min_value` argument allows to define the minimum value allowed. The default value for this argument is `nil`, which means that the minimum value is not validated by default.

### `string`

A `string` field allows to validate string values. In addition to the [common field options](#common-field-options), such fields support the following arguments:

#### `max_size`

The `max_size` argument allows to define the maximum size allowed for the string. The default value for this argument is `nil`, which means that the maximum size is not validated by default.

#### `min_size`

The `min_size` argument allows to define the minimum size allowed for the string. The default value for this argument is `nil`, which means that the minimum size is not validated by default.

#### `strip`

The `strip` argument allows to define whether the string value should be stripped of leading and trailing whitespaces. The default is `true`.

### `uuid`

A `uuid` field allows to validate Universally Unique IDentifiers values. Fields using this type are converted to `UUID` objects in Crystal.