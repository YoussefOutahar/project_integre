import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../../Core/Database/Controllers/reunion_controller.dart';
import '../../Core/Database/Controllers/users_controller.dart';
import '../../Core/Database/Models/compte.dart';
import '../../Core/Database/Models/reunion.dart';

class AddReunionPage extends StatefulWidget {
  const AddReunionPage({super.key});

  @override
  State<AddReunionPage> createState() => _AddReunionPageState();
}

class _AddReunionPageState extends State<AddReunionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Reunion"),
      ),
      body: FutureBuilder(
        future: UsersController.getAllAcountsFuture(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return InsideFuture(data: snapshot.data as List<Compte>);
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class InsideFuture extends StatefulWidget {
  const InsideFuture({super.key, required this.data});

  final List<Compte> data;

  @override
  State<InsideFuture> createState() => _InsideFutureState();
}

class _InsideFutureState extends State<InsideFuture> {
  late TextEditingController subjectController;
  DateTime? selectedDate;
  Compte? selectedProfesseur;
  List<String> selectedParticipants = [];

  @override
  void initState() {
    subjectController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: size.width * 0.7,
              height: size.height * 0.7,
              child: Row(
                children: [
                  const Spacer(),
                  Column(
                    children: [
                      const Spacer(),
                      const Text("Subject:"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: size.width * 0.3,
                        child: TextField(
                          controller: subjectController,
                          cursorColor: Theme.of(context).primaryColor,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2.0),
                            ),
                            focusColor: Theme.of(context).primaryColor,
                            contentPadding: const EdgeInsets.all(15),
                            border: const OutlineInputBorder(),
                            labelText: 'Subject',
                            labelStyle: TextStyle(
                                color: Theme.of(context).primaryColor),
                            prefixIcon: Icon(
                              Icons.subject,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text("Date:"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: size.width * 0.3,
                        height: size.height * 0.1,
                        child: DateTimePicker(
                          type: DateTimePickerType.dateTimeSeparate,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          icon: const Icon(Icons.event),
                          dateLabelText: 'Date',
                          timeLabelText: "Hour",
                          onChanged: (val) {
                            setState(() {
                              selectedDate = DateTime.parse(val);
                            });
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      const Spacer(),
                      Row(
                        children: [
                          const Text("Professeur:"),
                          DropdownButton2(
                            hint: const Text("Select User"),
                            value: selectedProfesseur,
                            //searchController: searchControllerForAdding,
                            items: [
                              for (Compte user in widget.data)
                                if (user.accType == 2)
                                  DropdownMenuItem(
                                    value: user,
                                    child: Text(user.name),
                                  )
                            ],
                            onChanged: (value) => setState(() {
                              selectedProfesseur = value;
                            }),
                          )
                        ],
                      ),
                      const Spacer(),
                      const Text("Participants:"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: size.width * 0.3,
                        height: size.height * 0.3,
                        child: ListView.builder(
                          itemCount: widget.data.length,
                          itemBuilder: (context, index) {
                            return CheckboxListTile(
                              title: Text(widget.data[index].name),
                              value: selectedParticipants
                                  .contains(widget.data[index].id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedParticipants
                                        .add(widget.data[index].id);
                                  } else {
                                    selectedParticipants
                                        .remove(widget.data[index].id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          const Spacer(),
          _buildButtons(),
        ],
      ),
    );
  }

  _buildButtons() {
    return Row(
      children: [
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            ReunionController.createReunion(Reunion(
              uid: Random().nextInt(1000000).toString(),
              subject: subjectController.text.isEmpty
                  ? "No Subject"
                  : subjectController.text,
              date: selectedDate ?? DateTime.now(),
              profId: selectedProfesseur?.id ?? "",
              participants: selectedParticipants,
            ));
            Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
