class_name ErrorMessage
extends Object
"""
Functions that emit specific error messages.
"""

# The formatted error string for when a signal fails to connect in a state machine.
static func signal_connect_failed(
	error_code: int, 
	signal_name: String,
	signal_source_node: String,
	connecting_node_parent: String,
	connecting_node: String,
	signal_method: String
) -> void:
	var message_template: String = "ERROR CODE %d\n" + \
			"Failed to connect %s signal from %s node to %s %s node method '%s'."
	printerr(
		message_template % [
			error_code,
			signal_name,
			signal_source_node,
			connecting_node_parent,
			connecting_node,
			signal_method
		]
	)


# The formatted error string for when a node's own signal fails to connect.
static func signal_connect_self_failed(
	error_code: int, 
	signal_name: String, 
	signal_source_node: String, 
	signal_method: String
) -> void:
	var message_template: String = "ERROR CODE %d\n" + \
			"Failed to connect %s own %s signal to its own method '%s'."
	printerr(
		message_template % [
			error_code,
			signal_name,
			signal_source_node,
			signal_method
		]
	)
