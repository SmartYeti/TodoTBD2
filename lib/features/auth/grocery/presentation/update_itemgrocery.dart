import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/core/enum/state_status.enum.dart';
import 'package:todo_list/core/global_widgets/snackbar.widget.dart';
import 'package:todo_list/core/utils/guard.dart';
import 'package:todo_list/features/auth/grocery/domain/grocery_bloc/grocery_bloc.dart';
import 'package:todo_list/features/auth/grocery/domain/models/grocery.model.dart';
import 'package:todo_list/features/auth/grocery/domain/models/update_grocery.model.dart';

class UpdateGroceryItemPage extends StatefulWidget {
  const UpdateGroceryItemPage({super.key, required this.groceryItemModel});
  final GroceryItemModel groceryItemModel;

  @override
  State<UpdateGroceryItemPage> createState() => _UpdateGroceryItemPageState();
}

class _UpdateGroceryItemPageState extends State<UpdateGroceryItemPage> {
  late String _updateItemId;
  late TextEditingController _updateProductName;
  late TextEditingController _updateQuantity;
  late TextEditingController _updatePrice;
  late GroceryItemBloc _groceryItemBloc;
  final GlobalKey<FormState> _formKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    _groceryItemBloc = BlocProvider.of<GroceryItemBloc>(context);
    widget.groceryItemModel;

    _updateItemId = widget.groceryItemModel.id;
    _updateProductName =
        TextEditingController(text: widget.groceryItemModel.productName);
    _updateQuantity =
        TextEditingController(text: widget.groceryItemModel.quantity);
    _updatePrice = TextEditingController(text: widget.groceryItemModel.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const SizedBox(
          height: 10,
          width: 10,
          child: Icon(Icons.update_sharp),
        ),
        title: const Text('Update Grocery Items'),
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: BlocConsumer<GroceryItemBloc, GroceryItemState>(
        bloc: _groceryItemBloc,
        listener: _itemListener,
        builder: (context, state) {
          if (state.stateStatus == StateStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: SizedBox(
                    width: 600,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _updateProductName,
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
                              labelText: 'Product Name',
                      ),
                      validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Product Name');
                      }
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: SizedBox(
                    width: 600,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _updateQuantity,
                      keyboardType: TextInputType.number,
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
                              labelText: 'Quantity',
                      ),
                      validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Quantity');
                      }
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: SizedBox(
                    width: 600,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _updatePrice,
                      keyboardType: TextInputType.number,
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
                              labelText: 'Price',
                      ),
                      validator: (String? val) {
                        return Guard.againstEmptyString(val, 'Price');
                      }
                    ),
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
                                foregroundColor: Colors.white),
                            onPressed: () {
                              _updateItem(context);
                            },
                            child: const Text('Update')),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 16),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white),
                            onPressed: () {
                              _updateItem(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _itemListener(BuildContext context, GroceryItemState state) {
    if (state.stateStatus == StateStatus.error) {
      SnackBarUtils.defualtSnackBar(state.errorMessage, context);
      return;
    }

    if (state.isUpdated) {
      Navigator.pop(context);
      SnackBarUtils.defualtSnackBar('Task successfully updated!', context);
      return;
    }
    
  }

  void _updateItem(BuildContext context) {
    if(_formKey.currentState!.validate()){
      _groceryItemBloc.add(
      UpdateGroceryEvent(
        updateGroceryModel: UpdateGroceryModel(
            id: _updateItemId,
            productName: _updateProductName.text,
            quantity: _updateQuantity.text,
            price: _updatePrice.text),
      ),
    );
    }
    
  }
}
