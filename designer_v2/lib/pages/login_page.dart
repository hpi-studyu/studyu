import 'package:provider/provider.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:flutter/material.dart';
import '../services/auth_store.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_theme.dart';
import 'package:studyu_designer_v2/flutter_flow/flutter_flow_widgets.dart';


class LoginPage extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final AuthService authService = Provider.of<AuthService>(context);
    //final theme = Theme.of(context); // todo needs to be replaced in flutterflow

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF25B8D9),
        automaticallyImplyLeading: true,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'StudyU',
              style: FlutterFlowTheme.of(context).title1.override(
                fontFamily: 'Poppins',
                color: FlutterFlowTheme.of(context).primaryBtnText,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(-0.35, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
                    child: Text(
                      'Learn more',
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme.of(context).lineColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional(-0.4, -0.2),
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(800, 0, 0, 0),
                child: Text(
                  'Do you already have an account?',
                  style: FlutterFlowTheme.of(context).bodyText1.override(
                    fontFamily: 'Poppins',
                    color: FlutterFlowTheme.of(context).primaryBtnText,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
              child: Text(
                'Sign in here',
                style: FlutterFlowTheme.of(context).bodyText1.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
        actions: [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Align(
                            alignment: AlignmentDirectional(0.4, 0.05),
                            child: Padding(
                              padding:
                              EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                              child: Container(
                                width: 600,
                                height: 600,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryColor,
                                    )
                                  ],
                                ),
                                alignment: AlignmentDirectional(
                                    0.1499999999999999, 0.10000000000000009),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment:
                                      AlignmentDirectional(-0.32, 0.91),
                                      child: FFButtonWidget(
                                        onPressed: authService.skipLogin,
                                        text: 'Button',
                                        options: FFButtonOptions(
                                          width: 130,
                                          height: 40,
                                          color: FlutterFlowTheme.of(context)
                                              .primaryColor,
                                          textStyle:
                                          FlutterFlowTheme.of(context)
                                              .subtitle2
                                              .override(
                                            fontFamily: 'Poppins',
                                            color: Colors.white,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.transparent,
                                            width: 1,
                                          ),
                                          borderRadius: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary,
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: Text('Skip login'.hardcoded),
          onPressed: authService.skipLogin,
        )
      )
    );
  }
}*/