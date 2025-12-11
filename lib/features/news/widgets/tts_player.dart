import 'package:flutter/material.dart';
import 'package:newsverse/core/services/tts/tts_service.dart';

class TTSPlayer extends StatefulWidget {
  final String articleContent;
  
  const TTSPlayer({super.key, required this.articleContent});
  
  @override
  _TTSPlayerState createState() => _TTSPlayerState();
}

class _TTSPlayerState extends State<TTSPlayer> {
  late TTSService _ttsService;
  bool _isPlaying = false;
  bool _isPaused = false;
  
  @override
  void initState() {
    super.initState();
    _ttsService = TTSService();
    _ttsService.init();
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(_isPlaying 
                ? Icons.stop 
                : Icons.play_arrow
              ),
              onPressed: _togglePlay,
            ),
            if (_isPlaying) IconButton(
              icon: Icon(_isPaused 
                ? Icons.play_arrow 
                : Icons.pause
              ),
              onPressed: _togglePause,
            ),
            const Expanded(
              child: Text('Nghe bài viết'),
            ),
            Icon(Icons.volume_up),
          ],
        ),
      ),
    );
  }
  
  void _togglePlay() async {
    if (_isPlaying) {
      await _ttsService.stop();
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
    } else {
      await _ttsService.speak(widget.articleContent);
      setState(() {
        _isPlaying = true;
      });
    }
  }
  
  void _togglePause() async {
    if (_isPaused) {
      await _ttsService.resume();
      setState(() {
        _isPaused = false;
      });
    } else {
      await _ttsService.pause();
      setState(() {
        _isPaused = true;
      });
    }
  }
  
  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }
}