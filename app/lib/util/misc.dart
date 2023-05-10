bool isRedundantClick(DateTime loginClickTime) {
  final currentTime = DateTime.now();
  if (loginClickTime == null) {
    loginClickTime = currentTime;
    return false;
  }
  int secondsUntilClicked = currentTime.difference(loginClickTime).inSeconds;
  // timeout submit button to disable multiple clicks
  if (secondsUntilClicked < 3) {
    print('complete button is still frozen');
    return true;
  }

  loginClickTime = currentTime;
  return false;
}
