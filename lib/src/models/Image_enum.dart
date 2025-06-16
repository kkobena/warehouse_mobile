enum ImageEnum {
  image0('The Flow', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_1.png'),
  image1('Through the Pane', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_2.png'),
  image2('Iridescence', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_3.png'),
  image3('Sea Change', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_4.png'),
  image4('Blue Symphony', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_5.png'),
  image5('When It Rains', 'Sponsored | Season 1 Now Streaming',
      'content_based_color_scheme_6.png');

  const ImageEnum(this.title, this.subtitle, this.url);
  final String title;
  final String subtitle;
  final String url;
}