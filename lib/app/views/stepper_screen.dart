import 'package:customerapp/app/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepperScreen extends StatefulWidget {
  @override
  _StepperScreenState createState() => _StepperScreenState();
}

class _StepperScreenState extends State<StepperScreen> {
  int _currentStep = 0;

  List<Step> getSteps() {
    return [
      Step(
        title: Text('Basic Info'),
        content: TextField(decoration: InputDecoration(labelText: 'Name')),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: Text('Email'),
        content: TextField(decoration: InputDecoration(labelText: 'Email')),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: Text('Preferences'),
        content: Text('Select your preferences here'),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  void _onStepContinue() {
    if (_currentStep < getSteps().length - 1) {
      setState(() => _currentStep += 1);
    } else {
      // Final step - save data and go to dashboard
      Get.offAll(() => DashboardView());
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: Stepper(
        currentStep: _currentStep,
        steps: getSteps(),
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
      ),
    );
  }
}