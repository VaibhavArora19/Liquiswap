const Button = (props) => {
    const classes = `btn ${props.classes}`;
    return <button className= {classes}>{props.label}</button>
};

export default Button;