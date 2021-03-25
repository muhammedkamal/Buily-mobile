import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editProduct';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlcontroller = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String prodId;
  Product _editedProduct;
  bool _isinit = false; //checks the intilization of the product item
  bool _isLoading = false;

  // triggerd by done button or by save icon in actions to save current data of the form
  void _saveForm() async {
    setState(() {
      _isLoading = true;
    });
    if (!_form.currentState.validate()) return;
    _form.currentState.save();
    if (prodId == null) {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error has occured'),
            content: Text('Please Try again in few minutes'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .updateProduct(prodId, _editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error has occured'),
            content: Text('Please Try again in few minutes'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Okay'),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (!_isinit) {
      prodId = ModalRoute.of(context).settings.arguments as String;
      prodId == null
          ? _editedProduct =
              Product(id: null, title: '', price: 0, imageUrl: '')
          : _editedProduct = Provider.of<Products>(context).findById(prodId);
      _imageUrlcontroller.text = _editedProduct.imageUrl;
    }
    _isinit = true;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateimage);
    super.initState();
  }

// this function only update image when the focus goes away from the url field
  void _updateimage() {
    setState(() {});
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateimage);
    _imageUrlcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            prodId == null ? Text('Edit Product') : Text(_editedProduct.title),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        //title
                        initialValue: _editedProduct.title,
                        validator: (value) {
                          return value.isEmpty
                              ? "Please input the title"
                              : null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Product Title',
                        ),
                        textInputAction: TextInputAction.next,
                        /* onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFN);
                  }, */
                        onSaved: (value) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: value,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        //price
                        initialValue: _editedProduct.price.toString(),
                        validator: (value) {
                          return value.isEmpty
                              ? "Please input the price"
                              : double.tryParse(value) == null
                                  ? "price should be a number"
                                  : double.parse(value) > 0
                                      ? null
                                      : "price should be bigger than zero";
                        },
                        decoration: InputDecoration(
                          labelText: 'Price',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: _editedProduct.title,
                              price: double.parse(value),
                              imageUrl: _editedProduct.imageUrl);
                        },
                      ),
                      TextFormField(
                        //discription
                        initialValue: _editedProduct.description,
                        validator: (value) {
                          return value.isEmpty
                              ? "Please input the title"
                              : value.length >= 10
                                  ? null
                                  : " Discription should be more han 10 characters";
                        },
                        decoration: InputDecoration(
                          labelText: 'Discription',
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                            title: _editedProduct.title,
                            price: _editedProduct.price,
                            description: value,
                            imageUrl: _editedProduct.imageUrl,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 10, right: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                            child: Container(
                              child: _imageUrlcontroller.text.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Enter a Url'),
                                    )
                                  : FittedBox(
                                      child: Image.network(
                                        _imageUrlcontroller.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              //image url
                              validator: (value) {
                                if (value.isEmpty) return "please enter a URL";
                                if (!(value.startsWith('http') ||
                                        value.startsWith('https')) &&
                                    !(value.endsWith('.png') ||
                                        value.endsWith('.jpg') ||
                                        value.endsWith(".jpeg")))
                                  return "please enter a Valid URl";
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Image Url',
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.url,
                              controller: _imageUrlcontroller,
                              focusNode: _imageUrlFocusNode,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavourite: _editedProduct.isFavourite,
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  description: _editedProduct.description,
                                  imageUrl: value,
                                );
                              },
                              onFieldSubmitted: (_) => _saveForm,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
