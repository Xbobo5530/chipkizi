import 'package:chipkizi/models/recording.dart';

final recording1 =  Recording(
    id: '001',
    title: 'niende wapi sasa?',
    createdBy: 'aaa',
    imageUrl:
        'https://takelessons.com/blog/wp-content/uploads/2015/08/15-Fantastic-Jazz-Songs-for-Female-Vocalists.jpg',
    upvoteCount: 23,
    playCount: 42);

final recording2 =  Recording(
    id: '002',
    title: 'the road ahead',
    createdBy: 'aab',
    imageUrl:
        'https://buzznigeria.com/wp-content/uploads/2014/01/Wizkid-2-640x427.jpg',
    upvoteCount: 34,
    playCount: 65);

final recordings = [recording1, recording2];
