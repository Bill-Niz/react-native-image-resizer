import { NativeModules } from 'react-native'

export default {
  createResizedImage: (path, width, height, format, quality, rotation = 0, outputPath) => {
    if (format !== 'JPEG' && format !== 'PNG' && format !== 'WEBP') {
      throw new Error('Only JPEG , PNG and WEBP format are supported by createResizedImage')
    }

    return new Promise((resolve, reject) => {
      NativeModules.ImageResizer.createResizedImage(
        path,
        width,
        height,
        format,
        quality,
        rotation,
        outputPath,
        (err, response) => {
          if (err) {
            return reject(err)
          }

          resolve(response)
        }
      )
    })
  }
}
