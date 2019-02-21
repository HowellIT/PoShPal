Deploy Module {
    By PSGalleryModule {
        FromSource Build\PoShPal
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}