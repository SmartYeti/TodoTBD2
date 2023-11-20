import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_title.models/grocery_title.model.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_title.models/update_title.model.dart';
import 'package:todo_list/features/auth/grocery/domain/title_grocery_bloc/title_grocery_bloc.dart';

class UpdateGroceryTitlePage extends StatefulWidget {
  const UpdateGroceryTitlePage({super.key, required this.groceryTitleModel});
  final GroceryTitleModel groceryTitleModel;

  @override
  State<UpdateGroceryTitlePage> createState() => _UpdateGroceryTitlePageState();
}

class _UpdateGroceryTitlePageState extends State<UpdateGroceryTitlePage> {
  late TitleGroceryBloc _titleGroceryBloc;

  late TextEditingController _titleController;
  late String _titleIDController;
  late String _updatedAt;
  final GlobalKey<FormState> _formKey = GlobalKey();


  @override
  void initState() {
    super.initState();

    _titleGroceryBloc = BlocProvider.of<TitleGroceryBloc>(context);
    _titleController =
        TextEditingController(text: widget.groceryTitleModel.title);
    _titleIDController = widget.groceryTitleModel.id;
    _updatedAt = widget.groceryTitleModel.createdAt!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TitleGroceryBloc, TitleGroceryState>(
      bloc: _titleGroceryBloc,
      listener: _updateListener,
      builder: (context, state) {
        if (state.stateStatus == StateStatus.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: const SizedBox(
                height: 10, width: 10, child: Icon(Icons.update, 
                color: Colors.white,)),
            title: const Text('Update Grocery'),
            titleTextStyle: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          body: Container(
            alignment: Alignment.center,
            child: SizedBox(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 15, top: 90, left: 15, bottom: 10),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.green,
                                  ),
                                  labelText: 'Title',
                          ),
                          validator: (String? val) {
                      return Guard.againstEmptyString(val, 'Title');
                    }
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  _updateTitleGorcery(context);
                                },
                                child: const Text('Update')),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 16),
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel')),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateListener(BuildContext context, TitleGroceryState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
      return;
    }

    if (state.isUpdated) {
      Navigator.pop(context);
      SnackBarUtils.defualtSnackBar('Grocery successfully updated!', context);
      return;
    }
    
  }

//update is working but when Navigator.pop(context) is compiled
//it gets an error, *Unexpected Null value*
//without telling what file is getting null value
  void _updateTitleGorcery(BuildContext context) {
    if (_formKey.currentState!.validate()){
       _titleGroceryBloc.add(
      UpdateTitleGroceryEvent(
        updateTitleGroceryModel: UpdateTitleGroceryModel(
          id: _titleIDController,
          title: _titleController.text,
          updatedAt: _updatedAt
        ),
      ),
    );
    }
   
  }
}
