import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:textfield_tags/textfield_tags.dart';

class ReactiveTextfieldTags<T> extends ReactiveFormField<T, List<String>> {
  ReactiveTextfieldTags({
    Key? key,
    FormControl<T>? formControl,
    String? formControlName,
    Map<String, ValidationMessageFunction>? validationMessages,
    required List<String> availableTags,
    Function(List<String> value)? onSubmittedCb,
    Function(String tag)? validator,
    String helperText = '',
    String hintText = '',
  }) : super(
      key: key,
      formControl: formControl,
      formControlName: formControlName,
      validationMessages: validationMessages,
      builder: (ReactiveFormFieldState<T, List<String>> field) {
        TextField? tf;
        final controller = TextfieldTagsController();
        return Autocomplete<String>(
          optionsViewBuilder: (context, onSelected, options) {
            return Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 10.0, vertical: 4.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final dynamic option = options.elementAt(index);
                        return TextButton(
                          onPressed: () {
                            onSelected(option);
                            tf!.onSubmitted!(option);
                            print("$option selected1");
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0),
                              child: Text(
                                option,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 74, 137, 92),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return const Iterable<String>.empty();
            }
            return availableTags.where((String option) {
              return option.contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selectedTag) {
            final t = List<String>.from(field.value!);
            t.add(selectedTag);
            field.didChange(t);
            if (field.control.valid) {
              onSubmittedCb?.call(t);
            }
            print("$selectedTag selected2");
          },
          fieldViewBuilder: (context, ttec, tfn, onFieldSubmitted) {
            return TextFieldTags(
              textEditingController: ttec,
              focusNode: tfn,
              textfieldTagsController: controller,
              initialTags: field.value,
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                print("validate jetzt");
                return field.control.validationErrorMessages.isEmpty ? null : field.control.validationErrorMessages.first.second;
              },
              inputfieldBuilder:
                  (context, tec, fn, error, onChanged, onSubmitted) {
                    return ((context, sc, tags, onTagDelete) {
                      if (field.control.valid) {
                        onSubmittedCb?.call(tags);
                      }
                      print("$tags inputfieldBuilder");
                      tf = TextField(
                        controller: tec,
                        focusNode: fn,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 74, 137, 92),
                                width: 3.0),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 74, 137, 92),
                                width: 3.0),
                          ),
                          helperText: helperText,
                          helperStyle: const TextStyle(
                            color: Color.fromARGB(255, 74, 137, 92),
                          ),
                          hintText: hintText,
                          errorText: error,
                          prefixIcon: tags.isNotEmpty
                              ? SingleChildScrollView(
                            controller: sc,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                                children: tags.map((String tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Color.fromARGB(
                                          255, 74, 137, 92),
                                    ),
                                    margin: const EdgeInsets.only(
                                        right: 10.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          onTap: () {
                                            print("$tag selected9");
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
                                          ),
                                          onTap: () {
                                            final t = List<String>.from(tags);
                                            t.remove(tag);
                                            field.didChange(t);
                                            onTagDelete(tag);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                          )
                              : null,
                        ),
                        onChanged: (value) {
                          onChanged!(value);
                        },
                        onSubmitted: (value) {
                          final t = List<String>.from(tags);
                          t.add(value);
                          field.didChange(t);
                          onSubmitted!(value);
                          print("$value submitted3");
                          //tf!.onSubmitted!(value);
                        },
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: tf,
                      );
                    });
                  },
            );
          },
        );
      }
  );
}
