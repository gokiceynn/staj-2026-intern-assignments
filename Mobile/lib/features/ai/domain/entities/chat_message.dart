import 'package:equatable/equatable.dart';

enum ChatRole { user, assistant }

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.role,
    required this.text,
    this.isError = false,
  });

  final ChatRole role;
  final String text;
  final bool isError;

  @override
  List<Object?> get props => [role, text, isError];
}
