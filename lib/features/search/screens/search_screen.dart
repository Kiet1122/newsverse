import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../home/home_provider.dart';
import '../../../models/article_model.dart';
import '../../../routes/route_names.dart';
import '../../home/widgets/personalized_news_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  /// Perform search with the given query
  void _performSearch(String query) {
    if (query.isNotEmpty) {
      context.read<HomeProvider>().searchNews(query);
    }
  }

  /// Clear search and reset to default news
  void _clearSearch() {
    _searchController.clear();
    context.read<HomeProvider>().loadCombinedNews();
    setState(() {});
  }

  /// Navigate to article detail screen
  void _onTapArticle(ArticleModel article) {
    Navigator.pushNamed(
      context,
      RouteNames.newsDetail,
      arguments: article,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm tin tức',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Enhanced search bar
          _buildSearchBar(theme, colors),
          
          // Search results with enhanced design
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildSearchContent(homeProvider, theme, colors),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the search bar widget
  Widget _buildSearchBar(ThemeData theme, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Nhập từ khóa tìm kiếm...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.primary,
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: IconButton(
                    key: ValueKey(_searchController.text),
                    icon: Icon(
                      Icons.clear_rounded,
                      color: colors.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                    onPressed: _clearSearch,
                  ),
                )
              : null,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colors.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          constraints: const BoxConstraints(
            minHeight: 56,
          ),
        ),
        onChanged: (value) {
          setState(() {});
          if (value.isEmpty) {
            _clearSearch();
          } else {
            // Debounce search to avoid too many API calls
            _debouncer.run(() => _performSearch(value));
          }
        },
        onSubmitted: _performSearch,
      ),
    );
  }

  /// Build the main search content based on current state
  Widget _buildSearchContent(HomeProvider provider, ThemeData theme, ColorScheme colors) {
    if (provider.isLoading) {
      return _buildLoadingState(theme, colors);
    }

    if (_searchController.text.isEmpty) {
      return _buildEmptyState(theme, colors);
    }

    if (provider.articles.isEmpty) {
      return _buildNoResultsState(theme, colors);
    }

    return _buildResultsList(provider);
  }

  /// Build loading state widget
  Widget _buildLoadingState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Đang tìm kiếm...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state widget (no search query)
  Widget _buildEmptyState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 100,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Tìm kiếm tin tức',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nhập từ khóa vào thanh tìm kiếm phía trên để bắt đầu khám phá các tin tức mới nhất',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build no results state widget
  Widget _buildNoResultsState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 100,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy kết quả',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                ),
                children: [
                  const TextSpan(text: 'Không tìm thấy kết quả cho '),
                  TextSpan(
                    text: '"${_searchController.text}"',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '. Vui lòng thử với từ khóa khác hoặc kiểm tra kết nối mạng.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build results list widget
  Widget _buildResultsList(HomeProvider provider) {
    return PersonalizedNewsList(
      articles: provider.articles,
      onTapArticle: _onTapArticle,
    );
  }
}

/// Debouncer class to prevent too many API calls
class Debouncer {
  final int milliseconds;
  VoidCallback? _callback;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  /// Run the callback after the specified delay
  void run(VoidCallback callback) {
    _callback = callback;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), _execute);
  }

  /// Execute the stored callback
  void _execute() {
    _callback?.call();
  }

  /// Clean up the timer
  void dispose() {
    _timer?.cancel();
  }
}