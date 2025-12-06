import 'package:flutter/material.dart';
import 'package:newsverse/core/services/firebase/like_service.dart';
import 'package:provider/provider.dart';

class LikeButton extends StatefulWidget {
  final String articleId;
  
  const LikeButton({super.key, required this.articleId});
  
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  int _likeCount = 0;
  
  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }
  
  Future<void> _checkIfLiked() async {
    final likeService = Provider.of<LikeService>(context, listen: false);
    final userId = 'current_user_id';
    final hasLiked = await likeService.hasUserLiked(widget.articleId, userId);
    setState(() {
      _isLiked = hasLiked;
    });
  }
  

  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? Colors.red : null,
          ),
          onPressed: _toggleLike,
        ),
        Text('$_likeCount'),
      ],
    );
  }
  
  void _toggleLike() async {
    final likeService = Provider.of<LikeService>(context, listen: false);
    final userId = 'current_user_id'; 
    await likeService.toggleLikeArticle(widget.articleId, userId);
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }
}