/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */

import React, { Component } from 'react'
import { StyleSheet, Text, View, Image, Alert, Button, TouchableOpacity } from 'react-native'
import ImagePicker from 'react-native-image-picker';
import ImageResizer from 'react-native-image-resizer'

const options = {
  title: 'Select Avatar',
  customButtons: [{ name: 'fb', title: 'Choose Photo from Facebook' }],
  storageOptions: {
    skipBackup: true,
    path: 'images',
  },
};

// import Spinner from 'react-native-gifted-spinner'


const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF'
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5
  },
  image: {
    width: 250,
    height: 250
  },
  resizeButton: {
    color: '#333333',
    fontWeight: 'bold',
    marginBottom: 5
  }
})

export default class App extends Component {
  constructor () {
    super()

    this.state = {
      resizedImageUri: '',
      loading: true
    }
  }

  _handleButtonPress = async () => {
    
      ImagePicker.showImagePicker(options, (response) => {
        const {fileSize,fileName} = response
        console.log("IMAGE",{fileSize,fileName});
      
        if (response.didCancel) {
          console.log('User cancelled image picker');
        } else if (response.error) {
          console.log('ImagePicker Error: ', response.error);
        } else if (response.customButton) {
          console.log('User tapped custom button: ', response.customButton);
        } else {
          const source = { uri: response.uri };
      
          // You can also display the image using data:
          // const source = { uri: 'data:image/jpeg;base64,' + response.data };
      
          this.setState({
            image: source,
          });
        }
      });
  }

  componentDidMount () {
   
  }

  resize () {
    ImageResizer.createResizedImage(this.state.image.uri, 1000, 900, 'WEBP', 70)
      .then((result) => {
        console.log(result)
        const { uri } = result
        this.setState({
          resizedImageUri: uri
        })
      })
      .catch(err => {
        console.log(err)
        return Alert.alert('Unable to resize the photo', 'Check the console for full the error message')
      }) 
  }

  render () {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Image Resizer example</Text>
        <Button title="Load Images" onPress={this._handleButtonPress} />
        <Text style={styles.instructions}>This is the original image:</Text>
        {this.state.image ? <Image style={styles.image} source={{ uri: this.state.image.uri }} /> : <Text style={styles.instructions}>Loading...</Text>}
        <Text style={styles.instructions}>Resized image:</Text>
        <TouchableOpacity onPress={() => this.resize()}>
          <Text style={styles.resizeButton}>Click me to resize the image</Text>
        </TouchableOpacity>
        {this.state.resizedImageUri ? (
          <Image style={styles.image} source={{ uri: this.state.resizedImageUri }} />
        ) : null}
      </View>
    )
  }
}
