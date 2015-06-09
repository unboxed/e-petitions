module FormHelper
  def form_row opts={}, &block
    css_classes = ['form-group']
    css_classes.push opts[:class] if opts[:class]
    css_classes.push 'error' if opts[:for] && opts[:for][0].errors[opts[:for][1]].any?
    content_tag :div, capture(&block), :class => css_classes.join(' ')
  end

  def countries_for_select
    [
      'Afghanistan',
      'Albania',
      'Algeria',
      'American Samoa',
      'Andorra',
      'Angola',
      'Anguilla (British Overseas Territory)',
      'Antigua and Barbuda',
      'Argentina',
      'Armenia',
      'Aruba/Dutch Caribbean',
      'Ascension Island (British Overseas Territory)',
      'Australia',
      'Austria',
      'Azerbaijan',
      'Bahamas',
      'Bahrain',
      'Bangladesh',
      'Barbados',
      'Belarus',
      'Belgium',
      'Belize',
      'Benin',
      'Bermuda (British Overseas Territory)',
      'Bhutan',
      'Bolivia',
      'Bosnia and Herzegovina',
      'Botswana',
      'Brazil',
      'British Antarctic Territory',
      'British Indian Ocean Territory',
      'British Virgin Islands (British Overseas Territory)',
      'Brunei',
      'Bulgaria',
      'Burkina Faso',
      'Burma',
      'Burundi',
      'Cambodia',
      'Cameroon',
      'Canada',
      'Cape Verde',
      'Cayman Islands (British Overseas Territory)',
      'Central African Republic',
      'Chad',
      'Channel Islands',
      'Chile',
      'China',
      'Colombia',
      'Comoros',
      'Congo',
      'Congo (Democratic Republic)',
      'Costa Rica',
      'Croatia',
      'Cuba',
      'Cyprus',
      'Czech Republic',
      'Denmark',
      'Djibouti',
      'Dominica, Commonwealth of',
      'Dominican Republic',
      'East Timor (Timor-Leste)',
      'Ecuador',
      'Egypt',
      'El Salvador',
      'Equatorial Guinea',
      'Eritrea',
      'Estonia',
      'Ethiopia',
      'Falkland Islands (British Overseas Territory)',
      'Fiji',
      'Finland',
      'France',
      'French Guiana',
      'French Polynesia',
      'Gabon',
      'Gambia',
      'Georgia',
      'Germany',
      'Ghana',
      'Gibraltar',
      'Greece',
      'Grenada',
      'Guadeloupe',
      'Guatemala',
      'Guinea',
      'Guinea-Bissau',
      'Guyana',
      'Haiti',
      'Honduras',
      'Hong Kong',
      'Hungary',
      'Iceland',
      'India',
      'Indonesia',
      'Iran',
      'Iraq',
      'Ireland',
      'Isle of Man',
      'Israel and the Occupied Palestinian Territories',
      'Italy',
      'Ivory Coast (Cote d''Ivoire)',
      'Jamaica',
      'Japan',
      'Jordan',
      'Kazakhstan',
      'Kenya',
      'Kiribati',
      'South Korea',
      'North Korea',
      'Kosovo',
      'Kuwait',
      'Kyrgyzstan',
      'Laos',
      'Latvia',
      'Lebanon',
      'Lesotho',
      'Liberia',
      'Libya',
      'Liechtenstein',
      'Lithuania',
      'Luxembourg',
      'Macao',
      'Macedonia',
      'Madagascar',
      'Malawi',
      'Malaysia',
      'Maldives',
      'Mali',
      'Malta',
      'Marshall Islands',
      'Martinique',
      'Mauritania',
      'Mauritius',
      'Mayotte',
      'Mexico',
      'Micronesia',
      'Moldova',
      'Monaco',
      'Mongolia',
      'Montenegro',
      'Montserrat (British Overseas Territory)',
      'Morocco',
      'Mozambique',
      'Namibia',
      'Nauru',
      'Nepal',
      'Netherlands',
      'New Caledonia',
      'New Zealand',
      'Nicaragua',
      'Niger',
      'Nigeria',
      'Norway',
      'Oman',
      'Pakistan',
      'Palau',
      'Panama',
      'Papua New Guinea',
      'Paraguay',
      'Peru',
      'Philippines',
      'Pitcairn',
      'Poland',
      'Portugal',
      'Qatar',
      'Romania',
      'Russian Federation',
      'Rwanda',
      'Réunion',
      'Samoa',
      'Saudi Arabia',
      'Senegal',
      'Serbia',
      'Seychelles',
      'Sierra Leone',
      'Singapore',
      'Slovakia',
      'Slovenia',
      'Solomon Islands',
      'Somalia',
      'South Africa',
      'South Georgia & South Sandwich Islands',
      'Spain',
      'Sri Lanka',
      'St Helena',
      'St Kitts and Nevis',
      'St Lucia',
      'St Pierre & Miquelon',
      'St Vincent and the Grenadines',
      'Sudan',
      'Suriname',
      'Swaziland',
      'Sweden',
      'Switzerland',
      'Syria',
      'São Tomé and Principe',
      'Taiwan',
      'Tajikistan',
      'Tanzania',
      'Thailand',
      'Togo',
      'Tonga',
      'Trinidad and Tobago',
      'Tristan da Cunha',
      'Tunisia',
      'Turkey',
      'Turkmenistan',
      'Turks & Caicos Islands (British Overseas Territory)',
      'Tuvalu',
      'Uganda',
      'Ukraine',
      'United Arab Emirates',
      'United Kingdom',
      'United States',
      'Uruguay',
      'Uzbekistan',
      'Vanuatu',
      'Venezuela',
      'Vietnam',
      'Wallis & Futuna',
      'Western Sahara',
      'Yemen',
      'Zambia',
      'Zimbabwe'
    ]
  end

  def error_messages_for_field(object, field_name, options = {})
    if errors = object.errors[field_name].presence
      content_tag :span, errors.join(' '), { class: 'error-message' }.merge(options)
    end
  end
end
