import 'package:flutter/material.dart';
import 'package:harpy/api/twitter/data/tweet.dart';
import 'package:harpy/api/twitter/error_handler.dart';
import 'package:harpy/models/timeline_model.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';

class UserTimelineModel extends TimelineModel {
  UserTimelineModel({
    @required this.userId,
  }) : assert(userId != null) {
    initTweets();
  }

  final int userId;

  static UserTimelineModel of(BuildContext context) {
    return Provider.of<UserTimelineModel>(context);
  }

  static final Logger _log = Logger("UserTimelineModel");

  @override
  Future<List<Tweet>> getCachedTweets() =>
      timelineDatabase.findUserTimelineTweets(userId);

  @override
  Future<void> updateTweets({
    Duration timeout,
    bool silentError = true,
  }) async {
    _log.fine("updating tweets");
    loadingInitialTweets = tweets.isEmpty;
    notifyListeners();

    List<Tweet> updatedTweets = await tweetService
        .getUserTimeline("$userId", timeout: timeout)
        .catchError(silentError ? (_) {} : twitterClientErrorHandler);
    // todo: silent twitter error handler

    if (updatedTweets != null) {
      final List<Tweet> cachedTweets = await getCachedTweets();
      updatedTweets = await copyHarpyData(
        origin: cachedTweets,
        target: updatedTweets,
      );

      tweets = updatedTweets;
      timelineDatabase.recordUserTimelineIds(userId, updatedTweets);
      tweetDatabase.recordTweetList(updatedTweets);
    }

    loadingInitialTweets = false;
    notifyListeners();
  }

  @override
  Future<List<Tweet>> requestMoreTweets() => tweetService
      .getUserTimeline("$userId", maxId: "${tweets.last.id - 1}")
      .catchError(twitterClientErrorHandler);
}
