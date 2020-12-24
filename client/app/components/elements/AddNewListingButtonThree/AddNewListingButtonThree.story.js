import withProps from '../../Styleguide/withProps';

import AddNewListingButtonThree from './AddNewListingButtonThree';

const { storiesOf } = storybookFacade;

storiesOf('Top bar')
  .add('AddNewListingButtonThree: default color', () => (
    withProps(AddNewListingButtonThree, {
      text: 'Post a request',
      url: '#',
    })))
  .add('AddNewListingButtonThree: custom color', () => (
    withProps(AddNewListingButtonThree, {
      text: 'Some long text from translations here',
      url: '#',
      customColor: 'red',
    })));
