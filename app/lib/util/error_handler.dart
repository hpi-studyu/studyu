import 'package:flutter/material.dart';

import '../models/app_error.dart';

class ErrorHandler {
  static Future<void> handleError(BuildContext context, AppError error) async {
    if (error.actions != null && error.actions!.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("An error occurred"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(error.message),
                //TODO: Improve UI for actions
                for (int i = 0; i < error.actions!.length; i++)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              const TextSpan(text: "Do you want to "),
                              TextSpan(
                                text: error.actions![i].actionText,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: " instead?"),
                            ],
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        if (error.actions![i].actionDescription != null)
                          Text(
                            error.actions![i].actionDescription!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(color: Colors.grey),
                          )
                        else
                          const SizedBox.shrink(),
                        if (error.actions!.length > 1 &&
                            i < error.actions!.length - 1)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Text(
                              "or",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: <Widget>[
              for (final action in error.actions!)
                TextButton(
                  onPressed: () async {
                    await action.callback.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(action.actionText),
                ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("An error occurred"),
            content: Text(error.message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    }
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
