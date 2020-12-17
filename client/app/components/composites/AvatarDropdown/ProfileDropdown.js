import { Component, PropTypes } from 'react';
import r, { a, div, span } from 'r-dom';
import classNames from 'classnames';

import css from './ProfileDropdown.css';
import inboxEmptyIcon from './images/inboxEmptyIcon.svg';
import profileIcon from './images/profileIcon.svg';
import settingsIcon from './images/settingsIcon.svg';
import transactionsIcon from './images/transactionsIcon.svg';
import heartIcon from './images/heartIcon.svg';
import { className } from '../../../utils/PropTypes';

const actionProps = function actionProps(action) {
  return (typeof action) === 'function' ?
    { onClick: action } :
    { href: action };
};

const ProfileActionCard = function ProfileActionCard({ icon, label, action, notificationCount }) {
  const notificationCountInArray = notificationCount > 0 ? [span({ className: label == 'Transactions' ? css.transactionCount : css.notificationCount }, notificationCount)] : [];
  return a({ ...actionProps(action), className: css.profileAction }, [
    div({ className: css.profileActionIconWrapper }, [
      div({ className: css.profileActionIcon, dangerouslySetInnerHTML: { __html: icon } }),
    ].concat(notificationCountInArray)),
    div({ className: css.profileActionLabel }, label),
  ]);
};

const eitherStringOrFunc = PropTypes.oneOfType([
  PropTypes.string,
  PropTypes.func,
]);

ProfileActionCard.propTypes = {
  icon: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  action: eitherStringOrFunc.isRequired,
  notificationCount: PropTypes.number,
};

class ProfileDropdown extends Component {
  render() {
    return div({
      className: classNames(this.props.classNames),
      ref: this.props.profileDropdownRef,
    }, [
      div({ className: css.rootArrowTop }),
      div({ className: css.rootArrowBelow }),
      div({ className: css.box }, [
        div({ className: css.profileActions }, [
          r(ProfileActionCard, { label: this.props.translations.inbox, icon: inboxEmptyIcon, action: this.props.actions.inboxAction, notificationCount: this.props.unReadDirectMessageCount }),

          r(ProfileActionCard, { label: this.props.translations.transactions, icon: transactionsIcon, action: this.props.actions.transactionsAction, notificationCount: this.props.unReadTransactionalMessagesCount }),

          r(ProfileActionCard, { label: this.props.translations.favorite, icon: heartIcon, action: this.props.actions.favoriteAction }),

          r(ProfileActionCard, { label: this.props.translations.myListing, icon: transactionsIcon, action: this.props.actions.myListingAction }),

          r(ProfileActionCard, { label: this.props.translations.profile, icon: profileIcon, action: this.props.actions.profileAction }),

          r(ProfileActionCard, { label: this.props.translations.settings, icon: settingsIcon, action: this.props.actions.settingsAction }),
        ]),
        div({ className: css.logoutArea }, [
          this.props.isAdmin ? a({
            className: css.adminLink,
            style: { color: this.props.customColor },
            ...actionProps(this.props.actions.adminDashboardAction),
          }, this.props.translations.adminDashboard) : null,
          a({
            className: css.logoutLink,
            ...actionProps(this.props.actions.logoutAction),
          }, this.props.translations.logout),
        ]),
      ]),
    ]);
  }
}

ProfileDropdown.propTypes = {
  actions: PropTypes.shape({
    inboxAction: eitherStringOrFunc.isRequired,
    myListingAction: eitherStringOrFunc.isRequired,
    transactionsAction: eitherStringOrFunc.isRequired,
    favoriteAction: eitherStringOrFunc.isRequired,
    profileAction: eitherStringOrFunc.isRequired,
    settingsAction: eitherStringOrFunc.isRequired,
    adminDashboardAction: eitherStringOrFunc.isRequired,
    logoutAction: eitherStringOrFunc.isRequired,
  }).isRequired,
  translations: PropTypes.shape({
    inbox: PropTypes.string.isRequired,
    myListing: PropTypes.string.isRequired,
    transactions: PropTypes.string.isRequired,
    favorite: PropTypes.string.isRequired,
    profile: PropTypes.string.isRequired,
    settings: PropTypes.string.isRequired,
    adminDashboard: PropTypes.string.isRequired,
    logout: PropTypes.string.isRequired,
  }),
  customColor: PropTypes.string.isRequired,
  isAdmin: PropTypes.bool.isRequired,
  classNames: PropTypes.arrayOf(className).isRequired,
  notificationCount: PropTypes.number,
  profileDropdownRef: PropTypes.func.isRequired,
};

export default ProfileDropdown;
