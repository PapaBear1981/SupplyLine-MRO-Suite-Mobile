import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../providers/tool_providers.dart';

class UserSelectionField extends ConsumerStatefulWidget {
  final String name;
  final UserModel? currentUser;
  final Function(UserModel?) onUserSelected;

  const UserSelectionField({
    super.key,
    required this.name,
    this.currentUser,
    required this.onUserSelected,
  });

  @override
  ConsumerState<UserSelectionField> createState() => _UserSelectionFieldState();
}

class _UserSelectionFieldState extends ConsumerState<UserSelectionField> {
  final TextEditingController _controller = TextEditingController();
  UserModel? _selectedUser;
  String? _searchQuery;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Default to current user
    if (widget.currentUser != null) {
      _selectedUser = widget.currentUser;
      _controller.text = widget.currentUser!.fullName;
      widget.onUserSelected(_selectedUser);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider(_searchQuery));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Assign to User',
            hintText: 'Search for a user or select yourself',
            prefixIcon: const Icon(Icons.person),
            suffixIcon: _selectedUser != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSelection,
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.isEmpty ? null : value;
              _showSuggestions = value.isNotEmpty;
              if (value.isEmpty) {
                _selectedUser = null;
                widget.onUserSelected(null);
              }
            });
          },
          onTap: () {
            setState(() {
              _showSuggestions = true;
            });
          },
          validator: (value) {
            if (_selectedUser == null) {
              return 'Please select a user';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        // Quick select buttons
        Wrap(
          spacing: 8,
          children: [
            if (widget.currentUser != null)
              ActionChip(
                avatar: const Icon(Icons.person, size: 16),
                label: const Text('Myself'),
                onPressed: () => _selectUser(widget.currentUser!),
                backgroundColor: _selectedUser?.id == widget.currentUser?.id
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
              ),
          ],
        ),
        // User suggestions
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: usersAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading users: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No users found'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUser?.id == user.id;

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        child: Text(
                          user.fullName.isNotEmpty
                              ? user.fullName[0].toUpperCase()
                              : user.username[0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user.fullName,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                      subtitle: Text(
                        '${user.username} • ${user.role}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            )
                          : null,
                      onTap: () => _selectUser(user),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _selectUser(UserModel user) {
    setState(() {
      _selectedUser = user;
      _controller.text = user.fullName;
      _showSuggestions = false;
    });
    widget.onUserSelected(user);

    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  void _clearSelection() {
    setState(() {
      _selectedUser = null;
      _controller.clear();
      _showSuggestions = false;
      _searchQuery = null;
    });
    widget.onUserSelected(null);
  }
}
