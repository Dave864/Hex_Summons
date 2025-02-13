class_name ErrorUtil
extends Object
"""
Functions that help catch or display errors when performing specific actions.
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


# This function connects a signal to the specified function in the current state
# and emits an error message if the connection failed.
static func connect_signal(
	signal_source_node: Object,
	signal_name: String,
	target: Object,
	function_name: String
) -> void:
	var e = signal_source_node.connect(signal_name, target, function_name)
	
	if e != OK:
		if signal_source_node.name != target.name:
			signal_connect_failed(
				e,
				signal_name,
				signal_source_node.name,
				signal_source_node.owner.name,
				target.name,
				function_name
			)
		else:
			signal_connect_self_failed(
				e,
				signal_name,
				target.name,
				function_name
			)
