import withProps from '../../Styleguide/withProps';

import AddNewListingButtonTwo from './AddNewListingButtonTwo';

const { storiesOf } = storybookFacade;

storiesOf('Top bar')
  .add('AddNewListingButtonTwo: default color', () => (
    withProps(AddNewListingButtonTwo, {
      text: 'Post a request',
      url: '#',
    })))
  .add('AddNewListingButtonTwo: custom color', () => (
    withProps(AddNewListingButtonTwo, {
      text: 'Some long text from translations here',
      url: '#',
      customColor: 'red',
    })));
